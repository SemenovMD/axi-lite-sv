module axil_converter_str

(
    input   logic                   aclk,
    input   logic                   aresetn,

    axil_if.s_axil                  s_axil,

    axis_if.m_axis                  m_axis,
    axis_if.s_axis                  s_axis
);

    // FSM WR
    typedef enum logic [1:0]
    {  
        IDLE_WR,
        RESP_WR,
        HAND_WR,
        STREAM_WR
    } state_type_wr;

    state_type_wr state_wr;

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            state_wr <= IDLE_WR;
            s_axil.awready <= 1'b0;
            s_axil.wready <= 1'b0;
            s_axil.bvalid <= 1'b0;
            s_axil.bresp <= 2'b00;
            m_axis.tvalid <= 1'b0;
        end else begin
            case (state_wr)
                IDLE_WR:
                    begin
                        case ({s_axil.awvalid, s_axil.wvalid})
                            2'b11:
                                begin
                                    state_wr <= RESP_WR;
                                    s_axil.awready <= 1'b1;
                                    s_axil.wready <= 1'b1;
                                    m_axis.tdata <= s_axil.wdata;
                                end
                            default:
                                begin
                                    state_wr <= IDLE_WR;
                                end
                        endcase
                    end
                RESP_WR:
                    begin
                        state_wr <= HAND_WR;
                        s_axil.awready <= 1'b0;
                        s_axil.wready <= 1'b0;
                        s_axil.bvalid <= 1'b1;
                    end
                HAND_WR:
                    begin
                        if (s_axil.bready) begin
                            state_wr <= STREAM_WR;
                            s_axil.bvalid <= 1'b0;
                            m_axis.tvalid <= 1'b1;
                        end
                    end
                STREAM_WR:
                    begin
                        if (m_axis.tready) begin
                            state_wr <= IDLE_WR;
                            m_axis.tvalid <= 1'b0;
                        end
                    end
            endcase
        end
    end

    // FSM RD
    typedef enum logic [1:0] 
    {  
        IDLE_RD,
        RESP_RD,
        HAND_RD
    } state_type_rd;

    state_type_rd state_rd;

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            state_rd <= IDLE_RD;
            s_axil.arready <= 1'b0;
            s_axil.rresp <= 2'b00;
            s_axil.rvalid <= 1'b0;
            s_axis.tready <= 1'b0;
        end else begin
            case (state_rd)
                IDLE_RD:
                    begin
                        if (s_axil.arvalid) begin
                            state_rd <= RESP_RD;
                            s_axil.arready <= 1'b1;
                        end
                    end
                RESP_RD:
                    begin
                        if (s_axis.tvalid) begin
                            state_rd <= HAND_RD;
                            s_axis.tready <= 1'b1;
                            s_axil.rdata <= s_axis.tdata;
                            s_axil.rvalid <= 1'b1;
                        end
                        
                        s_axil.arready <= 1'b0;
                    end
                HAND_RD:
                    begin
                        if (s_axil.rready) begin
                            state_rd <= IDLE_RD;
                            s_axil.rvalid <= 1'b0;                            
                        end

                        s_axis.tready <= 1'b0;
                    end
            endcase
        end
    end

endmodule