module axil_uart_master

    import axil_pkg ::*;

(
    input   logic                       aclk,
    input   logic                       aresetn,

    axis_if_uart.m_axis                 m_axis,
    axis_if_uart.s_axis                 s_axis,
    axil_if.m_axil                      m_axil
);

    logic   [AXI_DATA_WIDTH_UART-1:0]   data_slv;
    logic   [AXI_DATA_WIDTH_UART-1:0]   data_mstr;

    // FSM UART to AXI-Lite Master
    typedef enum logic [3:0]
    {  
        IDLE_AXIS_SLV,
        HAND_AXIS_SLV,
        IDLE_AXIL_WR,
        RESP_AXIL_WR,
        HAND_AXIL_WR,
        IDLE_AXIL_RD,
        RESP_AXIL_RD,
        HAND_AXIL_RD,
        IDLE_AXIS_MSTR,
        HAND_AXIS_MSTR
    } state_type_uart_master;

    state_type_uart_master state_uart_master;

    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_uart_master   <= IDLE_AXIS_SLV;

            s_axis.tready       <= 0;

            m_axil.awaddr       <= '0;
            m_axil.awvalid      <= 0;
            m_axil.wdata        <= '0;
            m_axil.wstrb        <= 4'hF;
            m_axil.wvalid       <= 0;
            m_axil.bready       <= 0;

            m_axil.araddr       <= '0;
            m_axil.arvalid      <= 0;
            m_axil.rready       <= 0;

            m_axis.tdata        <= '0;
            m_axis.tvalid       <= 0;

            data_slv            <= '0;
            data_mstr           <= '0;
        end else
        begin
            case (state_uart_master)
                IDLE_AXIS_SLV:
                    begin
                        if (!s_axis.tvalid)
                        begin
                            state_uart_master <= IDLE_AXIS_SLV;
                        end else
                        begin
                            state_uart_master <= HAND_AXIS_SLV;
                            data_slv <= s_axis.tdata;
                            s_axis.tready <= 1;
                        end
                    end
                HAND_AXIS_SLV:
                    begin
                        if (data_slv[AXI_DATA_WIDTH_UART-1])
                        begin
                            state_uart_master <= IDLE_AXIL_WR;
                        end else
                        begin
                            state_uart_master <= IDLE_AXIL_RD;
                        end

                        s_axis.tready <= 0;
                    end
                IDLE_AXIL_WR:
                    begin
                        state_uart_master <= RESP_AXIL_WR;
                        m_axil.awaddr <= data_slv[31:0];
                        m_axil.awvalid <= 1;
                        m_axil.wdata <= data_slv[63:32];
                        m_axil.wstrb <= 4'hF;
                        m_axil.wvalid <= 1;
                    end
                RESP_AXIL_WR:
                    begin
                        case ({m_axil.awready, m_axil.wready})
                            2'b00:
                                begin
                                    state_uart_master <= RESP_AXIL_WR;
                                end
                            2'b10:
                                begin
                                    state_uart_master <= RESP_AXIL_WR;
                                    m_axil.awaddr <= '0;
                                    m_axil.awvalid <= 0;
                                end
                            2'b01:
                                begin
                                    state_uart_master <= HAND_AXIL_WR;
                                    m_axil.wdata <= 0;
                                    m_axil.wstrb <= 4'h0;
                                    m_axil.wvalid <= 0;
                                    m_axil.bready <= 1;
                                end
                            2'b11:
                                begin
                                    state_uart_master <= HAND_AXIL_WR;
                                    m_axil.awaddr <= '0;
                                    m_axil.awvalid <= 0;
                                    m_axil.wdata <= 0;
                                    m_axil.wstrb <= 4'h0;
                                    m_axil.wvalid <= 0;
                                    m_axil.bready <= 1;
                                end
                        endcase
                    end
                HAND_AXIL_WR:
                    begin
                        if (!m_axil.bvalid)
                        begin
                            state_uart_master <= HAND_AXIL_WR;
                        end else
                        begin
                            state_uart_master <= IDLE_AXIS_MSTR;
                            m_axil.bready <= 0;
                            data_mstr[71] <= 1;
                            data_mstr[70:69] <= m_axil.bresp;
                            data_mstr[68:64] <= UART_MASTER_CODE_WR;
                            data_mstr[63:0] <= data_slv[63:0];
                        end
                    end
                IDLE_AXIL_RD:
                    begin
                        state_uart_master <= RESP_AXIL_RD;
                        m_axil.araddr <= data_slv[31:0];
                        m_axil.arvalid <= 1;
                    end
                RESP_AXIL_RD:
                    begin
                        if (!m_axil.arready)
                        begin
                            state_uart_master <= RESP_AXIL_RD;
                        end else
                        begin
                            state_uart_master <= HAND_AXIL_RD;
                            m_axil.araddr <= '0;
                            m_axil.arvalid <= 0;
                            m_axil.rready <= 1;
                        end
                    end
                HAND_AXIL_RD:
                    begin
                        if (!m_axil.rvalid)
                        begin
                            state_uart_master <= HAND_AXIL_RD;
                        end else
                        begin
                            state_uart_master <= IDLE_AXIS_MSTR;
                            data_mstr[71] <= 0;
                            data_mstr[70:69] <= m_axil.rresp;
                            data_mstr[68:64] <= UART_MASTER_CODE_RD;
                            data_mstr[63:32] <= m_axil.rdata;
                            data_mstr[31:0] <= data_slv[31:0];
                            m_axil.rready <= 0;
                        end
                    end
                IDLE_AXIS_MSTR:
                    begin
                        state_uart_master <= HAND_AXIS_MSTR;
                        m_axis.tdata <= data_mstr;
                        m_axis.tvalid <= 1;
                    end
                HAND_AXIS_MSTR:
                    begin
                        if (!m_axis.tready)
                        begin
                            state_uart_master <= HAND_AXIS_MSTR;  
                        end else
                        begin
                            state_uart_master <= IDLE_AXIS_SLV;
                            m_axis.tdata <= '0;
                            m_axis.tvalid <= 0;
                            data_slv <= '0;
                            data_mstr <= '0;
                        end
                    end
            endcase
        end
    end

endmodule