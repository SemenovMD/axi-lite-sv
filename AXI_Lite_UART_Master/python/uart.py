import serial
import time
import random

# Open serial port for data transmission
ComPort = serial.Serial('/dev/ttyUSB1', baudrate=115200)

# Define slaves with their ADDR_OFFSET and ADDR_RANGE
slaves = [
    {"offset": 0x10000000, "range": 0x000000FF},
    {"offset": 0x30000000, "range": 0x0000000F},
    {"offset": 0xF0000000, "range": 0x0000000F},
    {"offset": 0xA0000000, "range": 0x0000000F}
]

# Open files for recording transmitted, received, and decoded data
with open("rx_data.txt", "w") as file_rx, open("tx_decoded_data.txt", "w") as file_tx_decoded, open("rx_decoded_data.txt", "w") as file_rx_decoded:
    # Write headers to the decoded data files with aligned columns
    file_tx_decoded.write("№    |Header |Data    |Address |WR/RD\n")
    file_rx_decoded.write("№    |Header |Data    |Address |WR/RD|Response\n")

    def decode_frame(data_hex):
        """
        Decodes frame data and returns it as header, data, address, WR/RD, and response.
        Expected frame structure:
        - Header: 1 byte (2 characters)
        - Data: 4 bytes (8 characters)
        - Address: 4 bytes (8 characters)
        - WR/RD and Response: 1 byte (2 characters)
        """
        header = data_hex[0:2]
        data = data_hex[2:10]
        address = data_hex[10:18]
        codeword = data_hex[18:20]

        # Determine WR/RD
        if codeword[0] == 'a':
            wr_rd = "WR"
        elif codeword[0] == 'b':
            wr_rd = "RD"
        else:
            wr_rd = "ERROR"

        # Determine Response
        if codeword[1] == '0':
            response = "OKAY"
        elif codeword[1] == 'f':
            response = "DECERR"
        else:
            response = "ERROR"

        return header, data, address, wr_rd, response

    def generate_random_frame(slave, header_value, codeword_wr, codeword_rd):
        """
        Generates a random frame for transmission according to the slave's parameters.
        The last nibble is always 0.
        """
        data = ''.join(random.choices('0123456789abcdef', k=8))
        # Random address within the given range
        address = f"{random.randint(slave['offset'], slave['offset'] + slave['range']):08x}"
        # Randomly choose between WR and RD codeword
        codeword = random.choice([codeword_wr, codeword_rd])
        return f"{header_value}{data}{address}{codeword}"

    def process_frames(tx_data_lines):
        """
        Processes transmitted frames and writes the data to files.
        """
        tx_count = 0
        rx_count = 0

        # Initialize counters for response types for each slave
        response_counts_per_slave = [{"OKAY": 0, "DECERR": 0, "ERROR": 0} for _ in slaves]
        
        # Initialize total response counts
        total_response_counts = {"OKAY": 0, "DECERR": 0, "ERROR": 0}

        for tx_data in tx_data_lines:
            data_hex = tx_data.strip()
            data = bytes.fromhex(data_hex)
            
            # Transmit data
            ComPort.write(data)
            print(f"tx frame number: {tx_count}")
            print(f"tx data: {data_hex}")
            
            # Decode the transmitted data
            header, data_field, address, wr_rd, _ = decode_frame(data_hex)
            decoded_tx_string = f"{tx_count:<5}|{header:<7}|{data_field:<8}|{address:<8}|{wr_rd:<5}\n"
            file_tx_decoded.write(decoded_tx_string)
            
            # Wait for reception of data
            start_time = time.time()
            rx_received = False
            while time.time() - start_time < 1:
                if ComPort.in_waiting >= len(data):
                    # Receive data
                    x = ComPort.read(size=len(data))
                    data_hex_rx = x.hex()
                    print(f"rx frame number: {rx_count}")
                    print(f"rx data: {data_hex_rx}")
                    file_rx.write(data_hex_rx + "\n")
                    
                    # Decode the received data
                    header, data_field, address, wr_rd, response = decode_frame(data_hex_rx)
                    decoded_rx_string = f"{rx_count:<5}|{header:<7}|{data_field:<8}|{address:<8}|{wr_rd:<5}|{response:<6}\n"
                    file_rx_decoded.write(decoded_rx_string)

                    # Determine which slave the address belongs to and update response counts
                    address_int = int(address, 16)
                    for i, slave in enumerate(slaves):
                        if slave['offset'] <= address_int < slave['offset'] + slave['range']:
                            response_counts_per_slave[i][response] += 1
                            total_response_counts[response] += 1
                            break

                    rx_count += 1
                    rx_received = True
                    break
                time.sleep(0.01)
            
            if not rx_received:
                print(f"rx frame not received for tx frame number: {tx_count}")
                # Duplicate the transmitted frame as the received frame with "ERROR"
                file_rx.write(data_hex + "\n")
                decoded_rx_string = f"{rx_count:<5}|{header:<7}|{data_field:<8}|{address:<8}|ERROR|ERROR\n"
                file_rx_decoded.write(decoded_rx_string)

                # Determine which slave the address belongs to and update response counts
                address_int = int(address, 16)
                for i, slave in enumerate(slaves):
                    if slave['offset'] <= address_int < slave['offset'] + slave['range']:
                        response_counts_per_slave[i]["ERROR"] += 1
                        total_response_counts["ERROR"] += 1
                        break

                rx_count += 1
            
            tx_count += 1

        # Check for any remaining data in the buffer after transmission is complete
        while ComPort.in_waiting > 0:
            x = ComPort.read(size=ComPort.in_waiting)
            data_hex_rx = x.hex()
            print(f"rx frame number: {rx_count}")
            print(f"rx data: {data_hex_rx}")
            file_rx.write(data_hex_rx + "\n")
            
            # Decode the received data
            header, data_field, address, wr_rd, response = decode_frame(data_hex_rx)
            decoded_rx_string = f"{rx_count:<5}|{header:<7}|{data_field:<8}|{address:<8}|{wr_rd:<5}|{response:<6}\n"
            file_rx_decoded.write(decoded_rx_string)

            # Determine which slave the address belongs to and update response counts
            address_int = int(address, 16)
            for i, slave in enumerate(slaves):
                if slave['offset'] <= address_int < slave['offset'] + slave['range']:
                    response_counts_per_slave[i][response] += 1
                    total_response_counts[response] += 1
                    break

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
        header_value = input("Enter header value: ").strip()
        data = input("Enter data: ").strip()
        address = input("Enter address: ").strip()
        codeword_wr = input("Enter codeword wr: ").strip()
        codeword_rd = input("Enter codeword rd: ").strip()
        
        # Generate frames for WR and RD
        tx_data_lines = [generate_random_frame(slave, header_value, codeword_wr, codeword_rd) for slave in slaves]
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
        num_frames = 128  # Default number of frames
        header_value = "f0"  # Default header value
        write_code = "a0"  # Default write code
        read_code = "b0"  # Default read code
        
        # Define codeword values based on default parameters
        codeword_values = [write_code, read_code]
        
        # Generate random data and send it
        tx_data_lines = [generate_random_frame(random.choice(slaves), header_value, codeword_values[0], codeword_values[1]) for _ in range(num_frames)]
        response_counts_per_slave, total_response_counts = process_frames(tx_data_lines)
        report_data[3]["tx_frames"] = len(tx_data_lines)
        report_data[3]["rx_frames"] = sum(sum(counts.values()) for counts in response_counts_per_slave)
        report_data[3]["total_response_counts"] = total_response_counts

    elif mode == 4:
        # Random generation with user input parameters
        num_frames = int(input("Enter the number of frames to generate: ").strip())
        header_value = input("Enter header value: ").strip()
        codeword_wr = input("Enter codeword wr: ").strip()
        codeword_rd = input("Enter codeword rd: ").strip()
        
        # Generate random frames with user-defined parameters
        tx_data_lines = [generate_random_frame(slave, header_value, codeword_wr, codeword_rd) for _ in range(num_frames) for slave in slaves]
        response_counts_per_slave, total_response_counts = process_frames(tx_data_lines)
        report_data[4]["tx_frames"] = len(tx_data_lines)
        report_data[4]["rx_frames"] = sum(sum(counts.values()) for counts in response_counts_per_slave)
        report_data[4]["total_response_counts"] = total_response_counts

    # Generate report
    with open("report.txt", "w") as report_file:
        report_file.write(f"Report for Mode {mode}:\n")
        if mode == 1 or mode == 2:
            report_file.write("  Total:\n")
            report_file.write("    Response:\n")
            for response_type in ["OKAY", "DECERR", "ERROR"]:
                count = report_data[mode]["total_response_counts"].get(response_type, 0)
                report_file.write(f"      {response_type}: {count}\n")
        else:
            for slave_index, slave in enumerate(slaves):
                report_file.write(f"  Slave Device {slave_index}:\n")
                report_file.write("    Response:\n")
                for response_type in ["OKAY", "DECERR", "ERROR"]:
                    count = response_counts_per_slave[slave_index].get(response_type, 0)
                    report_file.write(f"      {response_type}: {count}\n")

# Close serial port
ComPort.close()
