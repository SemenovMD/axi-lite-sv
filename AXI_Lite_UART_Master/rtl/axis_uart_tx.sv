module axis_uart_tx

    import axil_pkg ::*;

(
    // Global signals
    input   logic                               aclk,
    input   logic                               aresetn,

    // Transmitter
    output  logic                               uart_tx,

    // Interface
    axis_if_uart.s_axis                         s_axis
);

    localparam COUNT_SPEED  = CLOCK/BAUD_RATE;

    logic [$clog2(COUNT_SPEED)-1:0]     count_baud;
    logic [2:0]                         count_bit;
    logic [3:0]                         count_byte;
    logic [71:0]                        uart_buf;

    typedef enum logic [2:0]
    {  
        IDLE_UART,
        HEADER_UART_START,
        HEADER_UART_DATA,
        HEADER_UART_STOP,
        DATA_UART_START,
        DATA_UART_DATA,
        DATA_UART_STOP_1,
        DATA_UART_STOP_2
    } state_type_uart_tx;

    state_type_uart_tx state_uart;

    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_uart <= IDLE_UART;
            count_baud <= '0;
            count_bit <= '0;
            count_byte <= '0;
            uart_buf <= '0;

            s_axis.tready <= 0;
        end else
        begin
            case (state_uart)
                IDLE_UART:
                    begin
                        if (!s_axis.tvalid)
                        begin
                            state_uart <= IDLE_UART;   
                        end else
                        begin
                            state_uart <= HEADER_UART_START;
                            s_axis.tready <= 1;
                            uart_buf <= s_axis.tdata;
                        end
                    end
                HEADER_UART_START:
                    begin
                        if (count_baud < COUNT_SPEED - 1)
                        begin
                            state_uart <= HEADER_UART_START;
                            count_baud <= count_baud + 1;
                        end else
                        begin
                            state_uart <= HEADER_UART_DATA;
                            count_baud <= '0;
                        end

                        s_axis.tready <= 0;
                    end
                HEADER_UART_DATA:
                    begin
                        if (!((count_baud == COUNT_SPEED - 1) && (count_bit == 8 - 1)))
                        begin
                            if (count_baud < COUNT_SPEED - 1)
                            begin
                                state_uart <= HEADER_UART_DATA;
                                count_baud <= count_baud + 1;
                            end else
                            begin
                                state_uart <= HEADER_UART_DATA;
                                count_baud <= '0;
                                count_bit <= count_bit + 1;
                            end
                        end else
                        begin
                            state_uart <= HEADER_UART_STOP;
                            count_baud <= '0;
                            count_bit <= '0 ;
                        end
                    end
                HEADER_UART_STOP:
                    begin
                        if (count_baud < COUNT_SPEED - 1)
                        begin
                            state_uart <= HEADER_UART_STOP;
                            count_baud <= count_baud + 1;
                        end else
                        begin
                            state_uart <= DATA_UART_START;
                            count_baud <= '0;
                        end
                    end
                DATA_UART_START:
                    begin
                        if (count_baud < COUNT_SPEED - 1)
                        begin
                            state_uart <= DATA_UART_START;
                            count_baud <= count_baud + 1;
                        end else
                        begin
                            state_uart <= DATA_UART_DATA;
                            count_baud <= '0;
                        end
                    end
                DATA_UART_DATA:
                    begin
                        if (!((count_baud == COUNT_SPEED - 1) && (count_bit == 8 - 1) && (count_byte == 9 - 1)))
                        begin
                            if (!((count_baud == COUNT_SPEED - 1) && (count_bit == 8 - 1)))
                            begin
                                if (count_baud < COUNT_SPEED - 1)
                                begin
                                    state_uart <= DATA_UART_DATA;
                                    count_baud <= count_baud + 1;
                                end else
                                begin
                                    state_uart <= DATA_UART_DATA;
                                    count_baud <= '0;
                                    count_bit <= count_bit + 1;
                                end
                            end else
                            begin
                                state_uart <= DATA_UART_STOP_1;
                                count_baud <= '0;
                                count_bit <= '0;
                                count_byte <= count_byte + 1;
                            end
                        end else
                        begin
                            state_uart <= DATA_UART_STOP_2;
                            count_baud <= '0;
                            count_bit <= '0;
                            count_byte <= '0;
                        end
                    end
                DATA_UART_STOP_1:
                    begin
                        if (count_baud < COUNT_SPEED - 1)
                        begin
                            state_uart <= DATA_UART_STOP_1;
                            count_baud <= count_baud + 1;
                        end else
                        begin
                            state_uart <= DATA_UART_START;
                            count_baud <= '0;
                        end
                    end
                DATA_UART_STOP_2:
                    begin
                        if (count_baud < COUNT_SPEED - 1)
                        begin
                            state_uart <= DATA_UART_STOP_2;
                            count_baud <= count_baud + 1;
                        end else
                        begin
                            state_uart <= IDLE_UART;
                            count_baud <= '0;
                        end
                    end
            endcase
        end
    end

    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            uart_tx <= 1;
        end else
        begin
            case (state_uart)
                IDLE_UART:
                    begin
                        uart_tx <= 1;
                    end
                HEADER_UART_START, DATA_UART_START:
                    begin
                        uart_tx <= 0;
                    end
                HEADER_UART_DATA:
                    begin
                        case (count_bit)
                            count_bit: uart_tx <= HEADER_UART[count_bit];
                        endcase
                    end
                DATA_UART_DATA:
                    begin
                        case (count_bit)
                            count_bit: uart_tx <= uart_buf[72 - 8 + count_bit - count_byte*8];
                        endcase
                    end
                HEADER_UART_STOP, DATA_UART_STOP_1, DATA_UART_STOP_2:
                    begin
                        uart_tx <= 1;
                    end
            endcase
        end
    end

endmodule