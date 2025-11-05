import serial
import time
import random

# Open serial port for data transmission
ComPort = serial.Serial('/dev/ttyUSB0', baudrate=115200)

# Define slaves with their ADDR_OFFSET and ADDR_RANGE
slaves = [
    {"offset": 0xc0000000, "range": 0x000000FF},
    {"offset": 0xc2000000, "range": 0x000000FF}
]

# Open files for recording transmitted, received, and decoded data
with open("rx_data.txt", "w") as file_rx, open("tx_decoded_data.txt", "w") as file_tx_decoded, open("rx_decoded_data.txt", "w") as file_rx_decoded:
    # Write headers to the decoded data files with aligned columns
    file_tx_decoded.write("№    |Header |Address |Data    |WR/RD\n")
    file_rx_decoded.write("№    |Header |Address |Data    |WR/RD|Response\n")

    def decode_frame(data_hex):
        """
        Decodes frame data according to new structure:
        TX: [1B Header][4B Address][4B Data][1B WR/RD] = 10 bytes = 20 hex chars
        RX: [1B Header][4B Address][4B Data][1B Response][1B WR/RD] = 11 bytes = 22 hex chars
        
        Response decoding:
        - Pre-last byte bits [1:0] = 00 -> OKAY
        - Pre-last byte bits [1:0] = 11 -> DECERR  
        - Other values -> ERROR
        """
        if len(data_hex) == 20:  # TX frame (10 bytes)
            header = data_hex[0:2]
            address = data_hex[2:10]    # 4 bytes address
            data_field = data_hex[10:18] # 4 bytes data
            wr_rd_byte = data_hex[18:20] # 1 byte WR/RD
            response = "NONE"  # No response in TX
        elif len(data_hex) == 22:  # RX frame (11 bytes)
            header = data_hex[0:2]
            address = data_hex[2:10]    # 4 bytes address
            data_field = data_hex[10:18] # 4 bytes data
            response_byte = data_hex[18:20] # 1 byte response (pre-last byte)
            wr_rd_byte = data_hex[20:22] # 1 byte WR/RD (last byte)
            
            # Convert response byte to binary and check bits [1:0]
            try:
                response_int = int(response_byte, 16)
                # Extract bits [1:0] (least significant 2 bits)
                response_bits = response_int & 0b00000011
                
                if response_bits == 0b00:
                    response = "OKAY"
                elif response_bits == 0b11:
                    response = "DECERR"
                else:
                    response = "ERROR"
            except ValueError:
                response = "ERROR"
        else:
            return "ERROR", "ERROR", "ERROR", "ERROR", "ERROR"

        # Determine WR/RD
        if wr_rd_byte == 'a1':
            wr_rd = "WR"
        elif wr_rd_byte == 'a2':
            wr_rd = "RD"
        else:
            wr_rd = "ERROR"

        return header, address, data_field, wr_rd, response

    def generate_random_frame(slave, header_value, wr_code, rd_code):
        """
        Generates a random frame for transmission according to new structure:
        [1B Header][4B Address][4B Data][1B WR/RD]
        """
        # Generate random data (4 bytes)
        data = ''.join(random.choices('0123456789abcdef', k=8))
        
        # Random address within the given range (4 bytes)
        address = f"{random.randint(slave['offset'], slave['offset'] + slave['range']):08x}"
        
        # Randomly choose between WR and RD codeword
        codeword = random.choice([wr_code, rd_code])
        
        return f"{header_value}{address}{data}{codeword}"

    def process_frames(tx_data_lines):
        """
        Processes transmitted frames and writes the data to files.
        """
        tx_count = 0
        rx_count = 0

        # Initialize counters
        response_counts_per_slave = [{"OKAY": 0, "DECERR": 0, "ERROR": 0} for _ in slaves]
        total_response_counts = {"OKAY": 0, "DECERR": 0, "ERROR": 0}

        # Clear serial buffer before starting
        ComPort.reset_input_buffer()
        ComPort.reset_output_buffer()

        for tx_data in tx_data_lines:
            data_hex = tx_data.strip()
            data = bytes.fromhex(data_hex)
            
            # Transmit ONE frame
            ComPort.write(data)
            print(f"tx frame number: {tx_count}")
            print(f"tx data: {data_hex}")
            
            # Decode the transmitted data
            header, address, data_field, wr_rd, _ = decode_frame(data_hex)
            decoded_tx_string = f"{tx_count:<5}|{header:<7}|{address:<8}|{data_field:<8}|{wr_rd:<5}\n"
            file_tx_decoded.write(decoded_tx_string)
            
            # Wait for ONE response with longer timeout
            start_time = time.time()
            rx_received = False
            expected_rx_length = 22
            
            # Ждем полный ответ 2 секунды
            while time.time() - start_time < 5:
                if ComPort.in_waiting >= expected_rx_length:
                    # Receive exactly one frame
                    x = ComPort.read(size=expected_rx_length)
                    data_hex_rx = x.hex()
                    
                    print(f"rx frame number: {rx_count}")
                    print(f"rx data: {data_hex_rx}")
                    file_rx.write(data_hex_rx + "\n")
                    
                    # Decode the received data
                    header_rx, address_rx, data_field_rx, wr_rd_rx, response = decode_frame(data_hex_rx)
                    decoded_rx_string = f"{rx_count:<5}|{header_rx:<7}|{address_rx:<8}|{data_field_rx:<8}|{wr_rd_rx:<5}|{response:<6}\n"
                    file_rx_decoded.write(decoded_rx_string)

                    # Update counters
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
                    rx_received = True
                    break
                time.sleep(0.01)
            
            if not rx_received:
                print(f"rx frame not received for tx frame number: {tx_count}")
                decoded_rx_string = f"{rx_count:<5}|{header:<7}|{address:<8}|{data_field:<8}|{wr_rd:<5}|ERROR\n"
                file_rx_decoded.write(decoded_rx_string)

                if address != "ERROR":
                    try:
                        address_int = int(address, 16)
                        for i, slave in enumerate(slaves):
                            if slave['offset'] <= address_int < slave['offset'] + slave['range']:
                                response_counts_per_slave[i]["ERROR"] += 1
                                total_response_counts["ERROR"] += 1
                                break
                    except ValueError:
                        total_response_counts["ERROR"] += 1
                else:
                    total_response_counts["ERROR"] += 1

                rx_count += 1
            
            tx_count += 1
            # Убрана задержка между пакетами - ждем ответ перед следующим

        # После основного цикла проверяем остатки (на всякий случай)
        remaining_time = time.time() + 3
        while time.time() < remaining_time and ComPort.in_waiting >= expected_rx_length:
            x = ComPort.read(size=expected_rx_length)
            data_hex_rx = x.hex()
            print(f"rx frame number: {rx_count} (late)")
            print(f"rx data: {data_hex_rx}")
            # ... обработка как выше
            rx_count += 1

        return response_counts_per_slave, total_response_counts

    # Initialize report data
    report_data = {
        1: {"tx_frames": 0, "rx_frames": 0, "total_response_counts": {"OKAY": 0, "DECERR": 0, "ERROR": 0}},
        2: {"tx_frames": 0, "rx_frames": 0, "total_response_counts": {"OKAY": 0, "DECERR": 0, "ERROR": 0}},
        3: {"tx_frames": 0, "rx_frames": 0, "total_response_counts": {"OKAY": 0, "DECERR": 0, "ERROR": 0}},
        4: {"tx_frames": 0, "rx_frames": 0, "total_response_counts": {"OKAY": 0, "DECERR": 0, "ERROR": 0}},
    }

    # Choose mode
    mode = int(input("Choose mode (1 - user input, 2 - load from tx_data, 3 - random generation with defaults, 4 - random generation with user input): ").strip())
    
    if mode == 1:
        # User input for a single frame
        header_value = input("Enter header value (e.g., f0): ").strip()
        data = input("Enter data (8 hex chars): ").strip()
        address = input("Enter address (8 hex chars): ").strip()
        wr_code = input("Enter WR code (e.g., a1): ").strip()
        rd_code = input("Enter RD code (e.g., a2): ").strip()
        
        # Generate frame manually
        frame = f"{header_value}{address}{data}{wr_code}"  # Using WR as example
        tx_data_lines = [frame]
        response_counts_per_slave, total_response_counts = process_frames(tx_data_lines)
        report_data[1]["tx_frames"] = len(tx_data_lines)
        report_data[1]["rx_frames"] = sum(sum(counts.values()) for counts in response_counts_per_slave)
        report_data[1]["total_response_counts"] = total_response_counts

    elif mode == 2:
        # Load transmitted data from tx_data
        try:
            with open("tx_data.txt", "r") as file_tx:
                tx_data_lines = file_tx.readlines()
            response_counts_per_slave, total_response_counts = process_frames(tx_data_lines)
            report_data[2]["tx_frames"] = len(tx_data_lines)
            report_data[2]["rx_frames"] = sum(sum(counts.values()) for counts in response_counts_per_slave)
            report_data[2]["total_response_counts"] = total_response_counts
        except FileNotFoundError:
            print("File tx_data.txt not found. Please ensure tx_data.txt exists in the working directory.")
            report_data[2] = {"tx_frames": 0, "rx_frames": 0, "total_response_counts": {"OKAY": 0, "DECERR": 0, "ERROR": 0}}

    elif mode == 3:
        # Random generation with default parameters
        num_frames = 4  # Default number of frames
        header_value = "f0"  # Default header value
        wr_code = "a1"  # Default write code
        rd_code = "a2"  # Default read code
        
        # Generate random data and send it
        tx_data_lines = [generate_random_frame(random.choice(slaves), header_value, wr_code, rd_code) for _ in range(num_frames)]
        response_counts_per_slave, total_response_counts = process_frames(tx_data_lines)
        report_data[3]["tx_frames"] = len(tx_data_lines)
        report_data[3]["rx_frames"] = sum(sum(counts.values()) for counts in response_counts_per_slave)
        report_data[3]["total_response_counts"] = total_response_counts

    elif mode == 4:
        # Random generation with user input parameters
        num_frames = int(input("Enter the number of frames to generate: ").strip())
        header_value = input("Enter header value (e.g., f0): ").strip()
        wr_code = input("Enter WR code (e.g., a1): ").strip()
        rd_code = input("Enter RD code (e.g., a2): ").strip()
        
        # Generate random frames with user-defined parameters
        tx_data_lines = [generate_random_frame(random.choice(slaves), header_value, wr_code, rd_code) for _ in range(num_frames)]
        response_counts_per_slave, total_response_counts = process_frames(tx_data_lines)
        report_data[4]["tx_frames"] = len(tx_data_lines)
        report_data[4]["rx_frames"] = sum(sum(counts.values()) for counts in response_counts_per_slave)
        report_data[4]["total_response_counts"] = total_response_counts

    # Generate report
    with open("report.txt", "w") as report_file:
        report_file.write(f"Report for Mode {mode}:\n")
        report_file.write(f"  Transmitted frames: {report_data[mode]['tx_frames']}\n")
        report_file.write(f"  Received frames: {report_data[mode]['rx_frames']}\n")
        report_file.write("  Response Summary:\n")
        for response_type in ["OKAY", "DECERR", "ERROR"]:
            count = report_data[mode]["total_response_counts"].get(response_type, 0)
            report_file.write(f"    {response_type}: {count}\n")

# Close serial port
ComPort.close()