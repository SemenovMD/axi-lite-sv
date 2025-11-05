module axis_uart_parser_gen

#(
    UART_BYTE_START =   8'hF0,
    UART_BYTE_WR    =   8'hA1,
    UART_BYTE_RD    =   8'hA2
)

(
    input   logic                               aclk,
    input   logic                               aresetn,

    output  logic                               wr_valid,
    input   logic                               wr_ready,
    output  logic   [31:0]                      wr_addr,
    output  logic   [31:0]                      wr_data,
    input   logic                               wr_done,
    input   logic   [1:0]                       wr_error,

    output  logic                               rd_valid,
    input   logic                               rd_ready,
    output  logic   [31:0]                      rd_addr,
    input   logic   [31:0]                      rd_data,
    input   logic                               rd_done,
    input   logic   [1:0]                       rd_error,

    axis_if.m_axis                              m_axis,
    axis_if.s_axis                              s_axis
);

    logic   [1:0]   count_byte_parser;
    logic   [3:0]   count_byte_generator;
    logic   [15:0]  count_delay;

    logic   [31:0]  parser_addr;
    logic   [31:0]  parser_data;
    logic           parser_flag_wr;
    logic           parser_flag_rd;

    logic           gen_wr_valid;
    logic           gen_wr_ready;
    logic   [1:0]   gen_wr_error;

    logic           gen_rd_valid;
    logic           gen_rd_ready;
    logic   [31:0]  gen_rd_data;
    logic   [1:0]   gen_rd_error;


    logic   [31:0]  gen_addr;
    logic   [31:0]  gen_data;
    logic   [7:0]   gen_error;
    logic   [7:0]   gen_wr_rd;
    logic   [87:0]  gen_frame;

    //////////////////////////////////////////////////////////////////////////////////
    // FSM UART Parser
    //////////////////////////////////////////////////////////////////////////////////
    typedef enum logic [1:0]
    {  
        UART_PARSER_START,
        UART_PARSER_ADDR,
        UART_PARSER_DATA,
        UART_PARSER_CODE_WR_RD
    } state_type_parser;

    state_type_parser state_parser;

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            state_parser <= UART_PARSER_START;
            s_axis.tready <= 1'b0;
            count_byte_parser <= 2'd0;
            parser_flag_wr <= 1'b0;
            parser_flag_rd <= 1'b0;
        end else begin
            case (state_parser)
                UART_PARSER_START:
                    begin
                        s_axis.tready <= 1'b1;
                        parser_flag_wr <= 1'b0;
                        parser_flag_rd <= 1'b0;
                        
                        if (s_axis.tvalid) begin
                            if (UART_BYTE_START == s_axis.tdata) begin
                                state_parser <= UART_PARSER_ADDR;  
                            end
                        end
                    end
                UART_PARSER_ADDR:
                    begin
                        if (s_axis.tvalid) begin
                            parser_addr[31 - count_byte_parser*8 -: 8] <= s_axis.tdata;
                            
                            if (~&count_byte_parser) begin
                                count_byte_parser <= count_byte_parser + 1'b1;
                            end else begin
                                state_parser <= UART_PARSER_DATA;
                                count_byte_parser <= 2'd0;
                            end
                        end
                    end
                UART_PARSER_DATA:
                    begin
                        if (s_axis.tvalid) begin
                            parser_data[31 - count_byte_parser*8 -: 8] <= s_axis.tdata;
                            
                            if (~&count_byte_parser) begin
                                count_byte_parser <= count_byte_parser + 1'b1;
                            end else begin
                                state_parser <= UART_PARSER_CODE_WR_RD;
                                count_byte_parser <= 2'd0;
                            end
                        end
                    end
                UART_PARSER_CODE_WR_RD:
                    begin
                        if (s_axis.tvalid) begin
                            state_parser <= UART_PARSER_START;
                            s_axis.tready <= 1'b0;

                            case (s_axis.tdata)
                                UART_BYTE_WR:
                                    begin
                                        parser_flag_wr <= 1'b1;
                                    end
                                UART_BYTE_RD:
                                    begin
                                        parser_flag_rd <= 1'b1;
                                    end
                            endcase
                        end
                    end
            endcase
        end
    end

    //////////////////////////////////////////////////////////////////////////////////
    // FSM UART Generator Frame
    //////////////////////////////////////////////////////////////////////////////////
    typedef enum logic [1:0]
    {  
        UART_GENERATOR_WAIT,
        UART_GENERATOR_DELAY,
        UART_GENERATOR_FRAME
    } state_generator_type;

    state_generator_type state_generator;


    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            state_generator <= UART_GENERATOR_WAIT;
            m_axis.tvalid <= 1'b0;
            gen_rd_ready <= 1'b0;
            gen_wr_ready <= 1'b0;
            count_byte_generator <= 4'd0;
            count_delay <= 16'd0;
        end else begin
            case (state_generator)
                UART_GENERATOR_WAIT:
                    begin
                        case ({gen_wr_valid, gen_rd_valid})
                            2'b00:
                                begin
                                    state_generator <= UART_GENERATOR_WAIT;
                                end
                            2'b01:
                                begin
                                    state_generator <= UART_GENERATOR_DELAY;
                                    gen_rd_ready <= 1'b1;
                                    gen_addr <= rd_addr;
                                    gen_data <= gen_rd_data;
                                    gen_wr_rd <= UART_BYTE_RD;
                                    gen_error <= {6'd0, gen_rd_error};
                                end 
                            2'b10, 2'b11:
                                begin
                                    state_generator <= UART_GENERATOR_DELAY;
                                    gen_wr_ready <= 1'b1;
                                    gen_addr <= wr_addr;
                                    gen_data <= wr_data;
                                    gen_wr_rd <= UART_BYTE_WR;
                                    gen_error <= {6'd0, gen_wr_error};
                                end
                        endcase
                    end
                UART_GENERATOR_DELAY:
                    begin
                        if (~&count_delay) begin
                            count_delay <= count_delay + 1'b1;
                        end else begin
                            state_generator <= UART_GENERATOR_FRAME;
                            count_delay <= 16'd0;
                        end

                        gen_rd_ready <= 1'b0;
                        gen_wr_ready <= 1'b0;
                    end
                UART_GENERATOR_FRAME:
                    begin
                        m_axis.tvalid <= 1'b1;
                        m_axis.tdata <= gen_frame[87 - count_byte_generator*8 -: 8];

                        if (m_axis.tready) begin
                            if (count_byte_generator != 4'd10) begin
                                count_byte_generator <= count_byte_generator + 1'b1;
                            end else begin
                                state_generator <= UART_GENERATOR_WAIT;
                                count_byte_generator <= 4'd0;
                                m_axis.tvalid <= 1'b0;
                            end
                        end
                    end
            endcase
        end
    end

    assign gen_frame = {
                            UART_BYTE_START,    // 1 byte 
                            gen_addr,           // 4 byte
                            gen_data,           // 4 byte
                            gen_error,          // 1 byte
                            gen_wr_rd           // 1 byte
                        };

    //////////////////////////////////////////////////////////////////////////////////
    // FSM Write
    //////////////////////////////////////////////////////////////////////////////////
    typedef enum logic [1:0]
    {
        IDLE_WR,
        HAND_WR,
        RESP_WR,
        WAIT_WR
    } state_type_wr;

    state_type_wr state_wr;

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            state_wr <= IDLE_WR;
            wr_valid <= 1'b0;
            gen_wr_valid <= 1'b0;
        end else begin
            case (state_wr)
                IDLE_WR:    
                    begin
                        if (parser_flag_wr) begin
                            state_wr <= HAND_WR;
                            wr_valid <= 1'b1;
                            wr_addr <= parser_addr;
                            wr_data <= parser_data;
                        end
                    end
                HAND_WR:
                    begin
                        if (wr_ready) begin
                            state_wr <= RESP_WR;
                            wr_valid <= 1'b0;
                        end
                    end
                RESP_WR:
                    begin
                        if (wr_done) begin
                            state_wr <= WAIT_WR;
                            gen_wr_valid <= 1'b1;
                            gen_wr_error <= wr_error;
                        end
                    end
                WAIT_WR:
                    begin
                        if (gen_wr_ready) begin
                            state_wr <= IDLE_WR;
                            gen_wr_valid <= 1'b0;
                        end
                    end
            endcase
        end
    end

    //////////////////////////////////////////////////////////////////////////////////
    // FSM Read
    //////////////////////////////////////////////////////////////////////////////////
    typedef enum logic [1:0]
    {
        IDLE_RD,
        HAND_RD,
        RESP_RD,
        WAIT_RD
    } state_type_rd;

    state_type_rd state_rd;

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            state_rd <= IDLE_RD;
            rd_valid <= 1'b0;
            gen_rd_valid <= 1'b0;
        end else begin
            case (state_rd)
                IDLE_RD:    
                    begin
                        if (parser_flag_rd) begin
                            state_rd <= HAND_RD;
                            rd_valid <= 1'b1;
                            rd_addr <= parser_addr;
                        end
                    end
                HAND_RD:
                    begin
                        if (rd_ready) begin
                            state_rd <= RESP_RD;
                            rd_valid <= 1'b0;
                        end
                    end
                RESP_RD:
                    begin
                        if (rd_done) begin
                            state_rd <= WAIT_RD;
                            gen_rd_valid <= 1'b1;
                            gen_rd_data <= rd_data;
                            gen_rd_error <= rd_error;
                        end
                    end
                WAIT_RD:
                    begin
                        if (gen_rd_ready) begin
                            state_rd <= IDLE_RD;
                            gen_rd_valid <= 1'b0;
                        end
                    end
            endcase
        end
    end

endmodule