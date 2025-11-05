# Makefile for running Python UART test script

# Variables
PYTHON  := python3
SCRIPT  := python/uart.py
LOG_DIR := python/logs

# Default target
all: run

# Run the Python script
run:
	@echo "Starting UART test..."
	$(PYTHON) $(SCRIPT)

# Run with sudo (if needed for serial port access)
run-sudo:
	@echo "Starting UART test with sudo..."
	sudo $(PYTHON) $(SCRIPT)

# Install required Python packages
install:
	@echo "Installing required packages..."
	pip3 install pyserial

# Show help
help:
	@echo "Available targets:"
	@echo "  run       - Run the Python script (default)"
	@echo "  run-sudo  - Run with sudo for serial port access"
	@echo "  install   - Install required Python packages"
	@echo "  help      - Show this help message"

# Create logs directory if it doesn't exist
$(LOG_DIR):
	mkdir -p $(LOG_DIR)

# Ensure logs directory exists before running
run: $(LOG_DIR)
run-sudo: $(LOG_DIR)

.PHONY: all run run-sudo clean install help