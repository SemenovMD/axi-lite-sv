module axil_decoder_addr_wr
#(
    parameter                               NUMBER_SLAVE                    =   4,
    parameter                               AXI_ADDR_WIDTH                  =   32,
    parameter   bit [AXI_ADDR_WIDTH-1:0]    AXI_ADDR_OFFSET [NUMBER_SLAVE]  =   '{default: '0},
    parameter   bit [AXI_ADDR_WIDTH-1:0]    AXI_ADDR_RANGE  [NUMBER_SLAVE]  =   '{default: 1}
)

(
    input   logic                           aclk,
    input   logic                           aresetn,

    input   logic   [AXI_ADDR_WIDTH-1:0]    addr,
    output  logic   [NUMBER_SLAVE:0]        slv_valid,

    input   logic                           m_axil_awvalid,
    input   logic                           m_axil_wvalid,

    input   logic                           m_axil_bvalid,
    input   logic                           m_axil_bready
);

    logic           [NUMBER_SLAVE:0]        slv_valid_wire;

    genvar i;

    typedef enum logic 
    {  
        IDLE,
        HAND
    } state_type_dec;

    state_type_dec state_dec;

    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_dec <= IDLE;
            slv_valid <= '0;
        end else
        begin
            case (state_dec)
                IDLE:
                    begin
                        if (!(m_axil_awvalid && m_axil_wvalid))
                        begin
                            state_dec <= IDLE;
                        end else
                        begin
                            state_dec <= HAND;
                            slv_valid <= slv_valid_wire;
                        end
                    end
                HAND:
                    begin
                        if (!(m_axil_bready && m_axil_bvalid))
                        begin
                            state_dec <= HAND; 
                        end else
                        begin
                            state_dec <= IDLE;
                            slv_valid <= 0;
                        end
                    end
            endcase
        end
    end

    generate
        for (i = 0; i < NUMBER_SLAVE; i++) begin : gen_slave
            assign slv_valid_wire[i] = (addr >= AXI_ADDR_OFFSET[i]) && (addr < (AXI_ADDR_OFFSET[i] + AXI_ADDR_RANGE[i]));
        end
    endgenerate

    assign slv_valid_wire[NUMBER_SLAVE] = ~|slv_valid_wire[NUMBER_SLAVE-1:0];

endmodule