import serial
import time

# Open serial port
ComPort = serial.Serial('/dev/ttyUSB1', baudrate=115200)

# Test frame
tx_data = "f0c000005300000000a2"

print(f"TX: {tx_data}")

# Send data
ComPort.write(bytes.fromhex(tx_data))
print("Frame sent")

# Wait for response
time.sleep(2)  # Ждем 2 секунды

# Read response
if ComPort.in_waiting >= 20:
    rx_bytes = ComPort.read(20)
    rx_data = rx_bytes.hex()
    print(f"RX: {rx_data}")
else:
    print("No response")

ComPort.close()