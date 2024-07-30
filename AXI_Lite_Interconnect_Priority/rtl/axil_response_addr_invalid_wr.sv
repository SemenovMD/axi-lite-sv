module axil_response_addr_invalid_wr

    import axil_pkg ::*;

(
    input   logic                                   aclk,
    input   logic                                   aresetn,

    // Channel Write Address
    input   logic   [AXI_ADDR_WIDTH-1:0]            s_axil_awaddr,
    input   logic                                   s_axil_awvalid,
    output  logic                                   s_axil_awready,

    // Channel Write Data
    input   logic   [AXI_DATA_WIDTH-1:0]            s_axil_wdata,
    input   logic   [AXI_DATA_WIDTH/4-1:0]          s_axil_wstrb,
    input   logic                                   s_axil_wvalid,
    output  logic                                   s_axil_wready,

    // Channel Write Response
    output  logic   [1:0]                           s_axil_bresp,
    output  logic                                   s_axil_bvalid,
    input   logic                                   s_axil_bready
);

    typedef enum logic [1:0]
    {  
        IDLE,
        RESP,
        HAND
    } state_type_wr;

    state_type_wr state_wr;

    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_wr        <= IDLE;
            s_axil_awready  <= 0;
            s_axil_wready   <= 0;
            s_axil_bvalid   <= 0;
            s_axil_bresp    <= 2'b00;
        end else
        begin
            case (state_wr)
                IDLE:
                    begin
                        case ({s_axil_awvalid, s_axil_wvalid})
                            2'b11:
                                begin
                                    state_wr <= RESP;
                                    s_axil_awready <= 1;
                                    s_axil_wready <= 1;
                                end
                            default:
                                begin
                                    state_wr <= IDLE;
                                end
                        endcase
                    end
                RESP:
                    begin
                        state_wr <= HAND;
                        s_axil_awready <= 0;
                        s_axil_wready <= 0;
                        s_axil_bvalid <= 1;
                        s_axil_bresp <= 2'b11;
                    end
                HAND:
                    begin
                        if (!s_axil_bready)
                        begin
                            state_wr <= HAND;
                        end else
                        begin
                            state_wr <= IDLE;
                            s_axil_bvalid <= 0;
                            s_axil_bresp <= 2'b00;
                        end
                    end
            endcase
        end
    end

endmodule