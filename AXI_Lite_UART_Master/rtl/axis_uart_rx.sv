module axis_uart_rx

    import axil_pkg ::*;

(
    // Global signals
    input   logic                               aclk,
    input   logic                               aresetn,

    // Receiver
    input   logic                               uart_rx,

    // Interface
    axis_if_uart.m_axis                         m_axis
);

    localparam COUNT_SPEED  = CLOCK/BAUD_RATE;

    logic [$clog2(COUNT_SPEED)-1:0]     count_baud;
    logic [$clog2(COUNT_SPEED)-1:0]     count_delay;   
    logic [2:0]                         count_bit;
    logic [3:0]                         count_byte;

    logic [71:0]                        uart_buf;
    logic [71:0]                        uart_reg;   

    logic [2:0]                         majority_in;
    logic                               majority_out;

    logic                               flag;

    // Конечный автомат UART приемника
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
    } state_type_uart_rx;

    state_type_uart_rx state_uart;

    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_uart <= IDLE_UART;
            uart_buf <= '0;
            uart_reg <= '0;
            count_baud <= '0;
            count_delay <= '0;
            count_bit <= '0;
            count_byte <= '0;
            flag <= 0;
        end else
        begin
            case (state_uart)
                IDLE_UART:
                    begin
                        if (uart_rx)
                        begin
                            state_uart <= IDLE_UART;
                        end else
                        begin
                            state_uart <= HEADER_UART_START;
                        end

                        flag <= 0;
                        uart_buf <= '0;
                    end
                HEADER_UART_START:
                    begin
                        if (count_baud < COUNT_SPEED - 1)
                        begin
                            state_uart <= HEADER_UART_START;
                            count_baud <= count_baud + 1;    
                        end else
                        begin
                            count_baud <= '0;

                            if (!majority_out)
                            begin
                                state_uart <= HEADER_UART_DATA;
                            end else
                            begin
                                state_uart <= IDLE_UART;
                            end
                        end
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
                            count_bit <= '0;
                        end

                        if (count_baud == (COUNT_SPEED/2 + 2))
                        begin
                            case (count_bit)
                                0: uart_buf[0] <= majority_out;
                                1: uart_buf[1] <= majority_out;
                                2: uart_buf[2] <= majority_out;
                                3: uart_buf[3] <= majority_out;
                                4: uart_buf[4] <= majority_out;
                                5: uart_buf[5] <= majority_out;
                                6: uart_buf[6] <= majority_out;
                                7: uart_buf[7] <= majority_out;                                                         
                            endcase
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
                            count_baud <= '0;

                            if (majority_out)
                            begin
                                if (uart_buf[7:0] == HEADER_UART)
                                begin
                                    state_uart <= DATA_UART_START;
                                    uart_buf <= '0;
                                end else
                                begin
                                    state_uart <= IDLE_UART;
                                end
                            end else
                            begin
                                state_uart <= IDLE_UART;
                            end
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
                            count_baud <= '0;

                            if (!majority_out)
                            begin
                                state_uart <= DATA_UART_DATA;
                            end else
                            begin
                                state_uart <= IDLE_UART;
                            end
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

                        if (count_baud == (COUNT_SPEED/2 + 2))
                        begin
                            uart_buf[72 + 1*count_bit - 8*count_byte - 8] <= majority_out;
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
                            count_baud <= '0;

                            if (majority_out)
                            begin
                                state_uart <= DATA_UART_START;
                            end else
                            begin
                                state_uart <= IDLE_UART;
                            end
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
                            count_baud <= '0;

                            if (majority_out)
                            begin
                                state_uart <= IDLE_UART;
                                flag <= 1;
                                uart_reg <= uart_buf;
                            end else
                            begin
                                state_uart <= IDLE_UART;
                            end
                        end
                    end
            endcase
        end
    end

    // Мажоритарный элемент
    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            majority_in <= '0;
        end else
        begin
            case (count_baud)
                COUNT_SPEED/2 - 1: majority_in[0] <= uart_rx;
                COUNT_SPEED/2    : majority_in[1] <= uart_rx;
                COUNT_SPEED/2 + 1: majority_in[2] <= uart_rx;
                default:           majority_in    <= majority_in;
            endcase
        end
    end

    always_comb 
    begin
        case (majority_in)
            3'b000, 3'b001, 3'b010, 3'b100: majority_out = 0;
            3'b011, 3'b101, 3'b110, 3'b111: majority_out = 1;
        endcase
    end

    // Конечный автомат AXI-Stream Master
    typedef enum logic 
    {  
        IDLE_WR,
        HAND_WR
    } state_type_wr;

    state_type_wr state_wr;

    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_wr <= IDLE_WR;
            m_axis.tdata <= '0;
            m_axis.tvalid <= 0;
        end else
        begin
            case (state_wr)
                IDLE_WR:
                    begin
                        if (!flag)
                        begin
                            state_wr <= IDLE_WR;
                        end else
                        begin
                            state_wr <= HAND_WR;
                            m_axis.tdata <= uart_reg;
                            m_axis.tvalid <= 1;
                        end
                    end
                HAND_WR:
                    begin
                        if (!m_axis.tready)
                        begin
                            state_wr <= HAND_WR;
                        end else
                        begin
                            state_wr <= IDLE_WR;
                            m_axis.tdata <= '0;
                            m_axis.tvalid <= 0;
                        end
                    end
            endcase
        end
    end

endmodule