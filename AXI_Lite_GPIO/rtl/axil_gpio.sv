module axil_gpio

    import axil_pkg ::*;

(
    input   logic                           aclk,
    input   logic                           aresetn,

    output  logic [GPIO_DATA_WIDTH-1:0]     gpio_out,

    axil_if.s_axil                          s_axil
);

    // FSM WRITE
    typedef enum logic [1:0]
    {  
        IDLE_WR,
        RESP_WR,
        HAND_WR
    } state_type_wr;

    state_type_wr state_wr;

    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_wr <= IDLE_WR;
            s_axil.awready <= 0;
            s_axil.wready <= 0;
            s_axil.bvalid <= 0;
            s_axil.bresp <= 2'b00;
        end else 
        begin
            case (state_wr)
                IDLE_WR:
                    begin
                        case ({s_axil.awvalid, s_axil_wvalid})
                            2'b11:
                                begin
                                    state_wr <= RESP_WR;
                                    s_axil.awready <= 1;
                                    s_axil.wready <= 1;
                                    gpio_out <= s_axil.wdata[GPIO_DATA_WIDTH-1:0];
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
                        s_axil.awready <= 0;
                        s_axil.wready <= 0;
                        s_axil.bvalid <= 1;
                        s_axil.bresp <= 2'b00;
                    end
                HAND_WR:
                    begin
                        if (!s_axil.bready)
                        begin
                            state_wr <= HAND_WR;
                        end else
                        begin
                            state_wr <= IDLE_WR;
                            s_axil.bvalid <= 0;
                            s_axil.bresp <= 2'b00;
                        end
                    end
            endcase 
        end
    end

    // FSM READ
    typedef enum logic [1:0]
    {  
        IDLE_RD,
        RESP_RD,
        HAND_RD
    } state_type_rd;

    state_type_rd state_rd;

    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_rd <= IDLE_RD;
            s_axil.arready <= 0;
            s_axil.rdata <= '0;
            s_axil.rresp <= 2'b00;
            s_axil.rvalid <= 0;
        end else 
        begin
            case (state_rd)
                IDLE_RD:
                    begin
                        if (!s_axil.arvalid)
                        begin
                            state_rd <= IDLE_RD;
                        end else
                        begin
                            state_rd <= RESP_RD;
                            s_axil.arready <= 1;
                        end
                    end
                RESP_RD:
                    begin
                        state_rd <= HAND_RD;
                        s_axil.arready <= 0;
                        s_axil.rdata[GPIO_DATA_WIDTH-1:0] <= gpio_out;
                        s_axil.rresp <= 2'b00;
                        s_axil.rvalid <= 1;
                    end
                HAND_RD:
                    begin
                        if (!s_axil.rready)
                        begin
                            state_rd <= HAND_RD;
                        end else
                        begin
                            state_rd <= IDLE_RD;
                            s_axil.rdata <= '0;
                            s_axil.rresp <= 2'b00;
                            s_axil.rvalid <= 0;
                        end
                    end
            endcase 
        end
    end

endmodule