module axil_response_addr_invalid_wr
#(
    parameter   AXI_DATA_WIDTH  =   32,
    parameter   AXI_ADDR_WIDTH  =   32
)

(
    input   logic                                   aclk,
    input   logic                                   aresetn,
    
    input   logic                                   slv_invalid,

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
        ACKN
    } state_type_wr;

    state_type_wr state_wr;

    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_wr        <= IDLE;
            s_axil_awready  <= 0;
            s_axil_bvalid   <= 0;
            s_axil_bresp    <= 2'b00;
        end else
        begin
            case (state_wr)
                IDLE:
                    begin
                        if (!slv_invalid)
                        begin
                            state_wr <= IDLE;
                        end else
                        begin
                            state_wr <= RESP;
                            s_axil_awready <= 1;
                        end
                    end
                RESP:
                    begin
                        state_wr <= ACKN;
                        s_axil_awready <= 0;
                        s_axil_bvalid <= 1;
                        s_axil_bresp <= 2'b11;
                    end
                ACKN:
                    begin
                        if (!s_axil_bready)
                        begin
                            state_wr <= ACKN;
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