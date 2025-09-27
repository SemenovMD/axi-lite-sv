module axil_master

(
	input   logic                           aclk,
	input   logic                           aresetn,

    input   logic                           wr_valid,
    output  logic                           wr_ready,
    input   logic   [AXI_ADDR_WIDTH-1:0]    wr_addr,
    input   logic   [AXI_DATA_WIDTH-1:0]    wr_data,
    output  logic                           wr_done,
    output  logic   [1:0]                   wr_error,

    input   logic                           rd_valid,
    output  logic                           rd_ready,
    input   logic   [AXI_ADDR_WIDTH-1:0]    rd_addr,
    output  logic   [AXI_DATA_WIDTH-1:0]    rd_data,
    output  logic                           rd_done,
    output  logic   [1:0]                   rd_error,

	axil_if.m_axil                          m_axil
);

    logic   [1:0]   wr_flag;

    // FSM AXI-Lite Master WRITE
    typedef enum logic [1:0]
    {
        WRITE_IDLE,
        WRITE_TRAN,
        WRITE_RESP
    } state_type_wr;
    
    state_type_wr state_wr;

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            state_wr <= WRITE_IDLE;
            m_axil.awvalid <= 1'b0;
            m_axil.wvalid <= 1'b0;
            m_axil.bready <= 1'b0;
            wr_ready <= 1'b0;
            wr_done <= 1'b0;
            wr_flag <= 2'b00;
        end else begin
            case (state_wr)
                WRITE_IDLE:
                    begin
                        if (wr_valid) begin
                            state_wr <= WRITE_TRAN;
                            m_axil.awvalid <= 1'b1;
                            m_axil.awaddr <= wr_addr;
                            m_axil.wvalid <= 1'b1;
                            m_axil.wdata <= wr_data;
                            m_axil.wstrb <= 4'hF;
                            wr_ready <= 1'b1;
                        end

                        wr_done <= 1'b0;
                    end
                WRITE_TRAN:
                    begin
                        case ({m_axil.wready, m_axil.awready})
                            2'b00:
                                begin
                                    state_wr <= WRITE_TRAN;
                                end
                            2'b01:
                                begin
                                    if (wr_flag[0]) begin
                                        state_wr <= WRITE_RESP;
                                        m_axil.bready <= 1'b1;
                                    end

                                    wr_flag[1] <= 1'b1;
                                    m_axil.awvalid <= 1'b0;
                                end
                            2'b10:
                                begin
                                    if (wr_flag[1]) begin
                                        state_wr <= WRITE_RESP;
                                        m_axil.bready <= 1'b1;
                                    end

                                    wr_flag[0] <= 1'b1;
                                    m_axil.wvalid <= 1'b0;
                                end
                            2'b11:
                                begin
                                    state_wr <= WRITE_RESP;
                                    m_axil.awvalid <= 1'b0;
                                    m_axil.wvalid <= 1'b0;
                                    m_axil.bready <= 1'b1;
                                end
                        endcase

                        wr_ready <= 1'b0;
                    end
                WRITE_RESP:
                    begin
                        if (m_axil.bvalid) begin
                            state_wr <= WRITE_IDLE;
                            m_axil.bready <= 1'b0;
                            wr_error <= m_axil.bresp;
                            wr_done <= 1'b1;
                        end

                        wr_flag <= 2'b00;
                    end
                default:
                    begin
                        state_wr <= WRITE_IDLE;
                        m_axil.awvalid <= 1'b0;
                        m_axil.wvalid <= 1'b0;
                        m_axil.bready <= 1'b0;
                        wr_ready <= 1'b0;
                        wr_done <= 1'b0;
                        wr_flag <= 2'b00;
                    end
            endcase
        end
    end

    // FSM AXI-Lite Master READ
    typedef enum logic [1:0]
    {
        READ_IDLE,
        READ_ADDR,
        READ_DATA
    } state_type_rd;

    state_type_rd state_rd;

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            state_rd <= READ_IDLE;
            m_axil.arvalid <= 1'b0;
            m_axil.rready <= 1'b0;
            rd_ready <= 1'b0;
            rd_done <= 1'b0;
        end else begin
            case (state_rd)
                READ_IDLE:
                    begin
                        if (rd_valid) begin
                            state_rd <= READ_ADDR;
                            m_axil.araddr <= rd_addr;
                            m_axil.arvalid <= 1'b1;
                            rd_ready <= 1'b1;
                        end

                        rd_done <= 1'b0;
                    end
                READ_ADDR:
                    begin
                        if (m_axil.arready) begin
                            state_rd <= READ_DATA;
                            m_axil.arvalid <= 1'b0;
                            m_axil.rready <= 1'b1;
                        end

                        rd_ready <= 1'b0;
                    end
                READ_DATA:
                    begin
                        if (m_axil.rvalid) begin
                            state_rd <= READ_IDLE;
                            m_axil.rready <= 1'b0;
                            rd_data <= m_axil.rdata;
                            rd_error <= m_axil.rresp;
                            rd_done <= 1'b1;
                        end
                    end
                default:
                    begin
                        state_rd <= READ_IDLE;
                        m_axil.arvalid <= 1'b0;
                        m_axil.rready <= 1'b0;
                        rd_ready <= 1'b0;
                        rd_done <= 1'b0;
                    end
            endcase
        end
    end

endmodule