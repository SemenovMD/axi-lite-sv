module axil_response_addr_invalid_rd
#(
    parameter   AXI_ADDR_WIDTH  =   32,
    parameter   AXI_DATA_WIDTH  =   32
)

(
    input   logic                                   aclk,
    input   logic                                   aresetn,

    // Channel Read Address
    input   logic   [AXI_ADDR_WIDTH-1:0]            s_axil_araddr,
    input   logic                                   s_axil_arvalid,
    output  logic                                   s_axil_arready,

    // Channel Read Data
    output  logic   [AXI_DATA_WIDTH-1:0]            s_axil_rdata,
    output  logic   [1:0]                           s_axil_rresp,
    output  logic                                   s_axil_rvalid,
    input   logic                                   s_axil_rready
);

    typedef enum logic [1:0]
    {  
        IDLE,
        RESP,
        HAND
    } state_type_wr;

    state_type_wr state_rd;

    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_rd        <= IDLE;
            s_axil_arready  <= 0;
            s_axil_rdata    <= '0;
            s_axil_rvalid   <= 0;
            s_axil_rresp    <= 2'b00;
        end else
        begin
            case (state_rd)
                IDLE:
                    begin
                        if (!s_axil_arvalid)
                        begin
                            state_rd <= IDLE;
                        end else
                        begin
                            state_rd <= RESP;
                            s_axil_arready <= 1;
                        end
                    end
                RESP:
                    begin
                        state_rd <= HAND;
                        s_axil_arready <= 0;
                        s_axil_rdata <= '1;
                        s_axil_rvalid <= 1;
                        s_axil_rresp <= 2'b11;
                    end
                HAND:
                    begin
                        if (!s_axil_rready)
                        begin
                            state_rd <= HAND;
                        end else
                        begin
                            state_rd <= IDLE;
                            s_axil_rdata <= '0;
                            s_axil_rvalid <= 0;
                            s_axil_rresp <= 2'b00;
                        end
                    end
            endcase
        end
    end

endmodule