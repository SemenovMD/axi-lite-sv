import serial
import time
import random
import sys
import os

def main():
    log_dir = "python/logs"
    os.makedirs(log_dir, exist_ok=True)
    
    try:
        ComPort = serial.Serial(
            '/dev/ttyACM0', 
            baudrate=921600, 
            timeout=0.001,
            write_timeout=0.1,
            bytesize=serial.EIGHTBITS,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE
        )
        print("Serial port opened successfully")
        
    except serial.SerialException as e:
        print(f"Error opening serial port: {e}")
        return
    except Exception as e:
        print(f"Unexpected error opening serial port: {e}")
        return

    slaves = [
        {"offset": 0xc0000000, "range": 0x00000FFF},
        {"offset": 0xc2000000, "range": 0x00000FFF}
    ]

    try:
        with open(f"{log_dir}/rx_data.txt", "w") as file_rx, \
             open(f"{log_dir}/tx_decoded_data.txt", "w") as file_tx_decoded, \
             open(f"{log_dir}/rx_decoded_data.txt", "w") as file_rx_decoded:
            
            file_tx_decoded.write("№    |Header |Address |Data    |WR/RD\n")
            file_rx_decoded.write("№    |Header |Address |Data    |WR/RD|Response\n")

            def decode_frame(data_hex):
                """Decodes frame data"""
                try:
                    if len(data_hex) == 20:
                        header = data_hex[0:2]
                        address = data_hex[2:10]
                        data_field = data_hex[10:18]
                        wr_rd_byte = data_hex[18:20]
                        response = "NONE"
                    elif len(data_hex) == 22:
                        header = data_hex[0:2]
                        address = data_hex[2:10]
                        data_field = data_hex[10:18]
                        response_byte = data_hex[18:20]
                        wr_rd_byte = data_hex[20:22]
                        
                        response_int = int(response_byte, 16)
                        response_bits = response_int & 0b00000011
                        
                        if response_bits == 0b00:
                            response = "OKAY"
                        elif response_bits == 0b11:
                            response = "DECERR"
                        else:
                            response = "ERROR"
                    else:
                        return "ERROR", "ERROR", "ERROR", "ERROR", "ERROR"

                    if wr_rd_byte == 'a1':
                        wr_rd = "WR"
                    elif wr_rd_byte == 'a2':
                        wr_rd = "RD"
                    else:
                        wr_rd = "ERROR"

                    return header, address, data_field, wr_rd, response
                    
                except Exception as e:
                    return "ERROR", "ERROR", "ERROR", "ERROR", "ERROR"

            def generate_random_frame(slave, header_value, wr_code, rd_code):
                """Generates a random frame for transmission"""
                try:
                    data = ''.join(random.choices('0123456789abcdef', k=8))
                    address = f"{random.randint(slave['offset'], slave['offset'] + slave['range']):08x}"
                    codeword = random.choice([wr_code, rd_code])
                    frame = f"{header_value}{address}{data}{codeword}"
                    
                    if len(frame) != 20:
                        return None
                        
                    return frame
                except Exception as e:
                    return None

            def read_response_fast(expected_length=22, timeout=0.1):
                """Ultra-fast response reading"""
                start_time = time.time()
                buffer = b''
                
                while time.time() - start_time < timeout:
                    if ComPort.in_waiting >= 11:
                        response = ComPort.read(11)
                        return response.hex()
                    time.sleep(0.0001)
                
                return None

            def process_frames_max_speed(tx_data_lines, byte_delay=0.001):
                """Max speed frame processing with byte delay"""
                try:
                    tx_count = 0
                    rx_count = 0

                    response_counts_per_slave = [{"OKAY": 0, "DECERR": 0, "ERROR": 0} for _ in slaves]
                    total_response_counts = {"OKAY": 0, "DECERR": 0, "ERROR": 0}

                    ComPort.reset_input_buffer()
                    ComPort.reset_output_buffer()

                    for tx_data in tx_data_lines:
                        if tx_data is None or len(tx_data.strip()) != 20:
                            continue
                            
                        try:
                            data_hex = tx_data.strip()
                            data = bytes.fromhex(data_hex)
                        except ValueError:
                            continue
                        
                        try:
                            print(f"num_frame: {tx_count}")
                            print(f"tx_frame: {data_hex}")
                            
                            for i, byte in enumerate(data):
                                ComPort.write(bytes([byte]))
                                ComPort.flush()
                                if i < len(data) - 1:
                                    time.sleep(byte_delay)
                            
                        except serial.SerialException:
                            break
                        
                        header, address, data_field, wr_rd, _ = decode_frame(data_hex)
                        decoded_tx_string = f"{tx_count:<5}|{header:<7}|{address:<8}|{data_field:<8}|{wr_rd:<5}\n"
                        file_tx_decoded.write(decoded_tx_string)
                        
                        rx_frame = read_response_fast(timeout=0.05)
                        
                        if rx_frame:
                            print(f"rx_frame: {rx_frame}")
                            file_rx.write(rx_frame + "\n")
                            
                            header_rx, address_rx, data_field_rx, wr_rd_rx, response = decode_frame(rx_frame)
                            decoded_rx_string = f"{rx_count:<5}|{header_rx:<7}|{address_rx:<8}|{data_field_rx:<8}|{wr_rd_rx:<5}|{response:<6}\n"
                            file_rx_decoded.write(decoded_rx_string)

                            if address_rx != "ERROR":
                                try:
                                    address_int = int(address_rx, 16)
                                    for i, slave in enumerate(slaves):
                                        if slave['offset'] <= address_int < slave['offset'] + slave['range']:
                                            response_counts_per_slave[i][response] += 1
                                            total_response_counts[response] += 1
                                            break
                                except ValueError:
                                    total_response_counts["ERROR"] += 1
                            else:
                                total_response_counts["ERROR"] += 1

                            rx_count += 1
                        else:
                            print("rx_frame: NO_RESPONSE")
                            decoded_rx_string = f"{rx_count:<5}|{header:<7}|{address:<8}|{data_field:<8}|{wr_rd:<5}|ERROR\n"
                            file_rx_decoded.write(decoded_rx_string)
                            total_response_counts["ERROR"] += 1
                            rx_count += 1
                        
                        tx_count += 1
                        
                        if tx_count < len(tx_data_lines):
                            time.sleep(0.001)

                    return response_counts_per_slave, total_response_counts
                    
                except Exception as e:
                    return [{"OKAY": 0, "DECERR": 0, "ERROR": 0} for _ in slaves], {"OKAY": 0, "DECERR": 0, "ERROR": 0}

            report_data = {
                1: {"tx_frames": 0, "rx_frames": 0, "total_response_counts": {"OKAY": 0, "DECERR": 0, "ERROR": 0}},
                2: {"tx_frames": 0, "rx_frames": 0, "total_response_counts": {"OKAY": 0, "DECERR": 0, "ERROR": 0}},
                3: {"tx_frames": 0, "rx_frames": 0, "total_response_counts": {"OKAY": 0, "DECERR": 0, "ERROR": 0}},
                4: {"tx_frames": 0, "rx_frames": 0, "total_response_counts": {"OKAY": 0, "DECERR": 0, "ERROR": 0}},
            }

            print(f"Log files will be saved in: {log_dir}/")
            
            mode = int(input("Choose mode (1 - user input, 2 - load from tx_data, 3 - random generation with defaults, 4 - random generation with user input): ").strip())
            
            if mode == 1:
                print("\n=== Mode 1: User Input ===")
                operation = input("Choose operation (1 - WRITE, 2 - READ): ").strip()
                
                header_value = input("Enter header value (e.g., f0): ").strip()
                address = input("Enter address (8 hex chars): ").strip()
                
                if operation == "1":  # WRITE
                    data = input("Enter data (8 hex chars): ").strip()
                    wr_code = "a1"
                    frame = f"{header_value}{address}{data}{wr_code}"
                    print(f"Creating WRITE frame: {frame}")
                    
                elif operation == "2":  # READ
                    data = "00000000"
                    rd_code = "a2"
                    frame = f"{header_value}{address}{data}{rd_code}"
                    print(f"Creating READ frame: {frame}")
                    
                else:
                    print("Invalid operation selected")
                    return
                
                if len(frame) == 20:
                    tx_data_lines = [frame]
                    response_counts_per_slave, total_response_counts = process_frames_max_speed(tx_data_lines)
                    report_data[1]["tx_frames"] = len(tx_data_lines)
                    report_data[1]["rx_frames"] = sum(sum(counts.values()) for counts in response_counts_per_slave)
                    report_data[1]["total_response_counts"] = total_response_counts
                else:
                    print(f"Error: Frame length is {len(frame)}, expected 20")

            elif mode == 2:
                print("\n=== Mode 2: Load from tx_data ===")
                tx_data_paths = [
                    f"{log_dir}/tx_data.txt",
                    "tx_data.txt"
                ]
                
                tx_data_lines = []
                used_path = ""
                
                for tx_data_path in tx_data_paths:
                    try:
                        with open(tx_data_path, "r") as file_tx:
                            tx_data_lines = [line.strip() for line in file_tx if line.strip()]
                        used_path = tx_data_path
                        print(f"Loaded {len(tx_data_lines)} frames from: {tx_data_path}")
                        break
                    except FileNotFoundError:
                        continue
                
                if not tx_data_lines:
                    print("File tx_data.txt not found in any of the following locations:")
                    for path in tx_data_paths:
                        print(f"  - {path}")
                    return
                
                valid_frames = []
                invalid_frames = []
                
                for frame in tx_data_lines:
                    if len(frame) == 20:
                        valid_frames.append(frame)
                    else:
                        invalid_frames.append(frame)
                
                if invalid_frames:
                    print(f"Warning: Found {len(invalid_frames)} invalid frames (wrong length):")
                    for frame in invalid_frames[:5]:  # Показываем только первые 5 невалидных кадров
                        print(f"  - '{frame}' (length: {len(frame)})")
                    if len(invalid_frames) > 5:
                        print(f"  ... and {len(invalid_frames) - 5} more")
                
                print(f"Processing {len(valid_frames)} valid frames...")
                
                if valid_frames:
                    response_counts_per_slave, total_response_counts = process_frames_max_speed(valid_frames)
                    report_data[2]["tx_frames"] = len(valid_frames)
                    report_data[2]["rx_frames"] = sum(sum(counts.values()) for counts in response_counts_per_slave)
                    report_data[2]["total_response_counts"] = total_response_counts
                else:
                    print("No valid frames found in the file")

            elif mode == 3:
                num_frames = 32
                header_value = "f0"
                wr_code = "a1"
                rd_code = "a2"
                
                tx_data_lines = []
                for i in range(num_frames):
                    frame = generate_random_frame(random.choice(slaves), header_value, wr_code, rd_code)
                    if frame:
                        tx_data_lines.append(frame)
                
                print(f"Testing max speed with {num_frames} frames...")
                start_time = time.time()
                
                response_counts_per_slave, total_response_counts = process_frames_max_speed(tx_data_lines)
                
                end_time = time.time()
                total_time = end_time - start_time
                frames_per_second = len(tx_data_lines) / total_time if total_time > 0 else 0
                
                report_data[3]["tx_frames"] = len(tx_data_lines)
                report_data[3]["rx_frames"] = sum(sum(counts.values()) for counts in response_counts_per_slave)
                report_data[3]["total_response_counts"] = total_response_counts
                
                print(f"\nSpeed test: {total_time:.3f}s for {len(tx_data_lines)} frames ({frames_per_second:.1f} fps)")

            elif mode == 4:
                num_frames = int(input("Enter the number of frames to generate: ").strip())
                header_value = input("Enter header value (e.g., f0): ").strip()
                wr_code = input("Enter WR code (e.g., a1): ").strip()
                rd_code = input("Enter RD code (e.g., a2): ").strip()
                
                tx_data_lines = []
                for i in range(num_frames):
                    frame = generate_random_frame(random.choice(slaves), header_value, wr_code, rd_code)
                    if frame:
                        tx_data_lines.append(frame)
                
                response_counts_per_slave, total_response_counts = process_frames_max_speed(tx_data_lines)
                report_data[4]["tx_frames"] = len(tx_data_lines)
                report_data[4]["rx_frames"] = sum(sum(counts.values()) for counts in response_counts_per_slave)
                report_data[4]["total_response_counts"] = total_response_counts

            else:
                print("Invalid mode selected")
                return

            report_filename = f"{log_dir}/report.txt"
            with open(report_filename, "w") as report_file:
                report_file.write(f"Report for Mode {mode}:\n")
                report_file.write("  Response Summary:\n")
                for response_type in ["OKAY", "DECERR", "ERROR"]:
                    count = report_data[mode]["total_response_counts"].get(response_type, 0)
                    report_file.write(f"    {response_type}: {count}\n")
            
            print(f"\nTest completed. Logs saved to {log_dir}/")
            print(f"Files created:")
            print(f"  - {log_dir}/rx_data.txt")
            print(f"  - {log_dir}/tx_decoded_data.txt")
            print(f"  - {log_dir}/rx_decoded_data.txt")
            print(f"  - {log_dir}/report.txt")

    except Exception as e:
        print(f"Error: {e}")

    finally:
        try:
            ComPort.close()
        except:
            pass

if __name__ == "__main__":
    main()