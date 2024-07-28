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
    output  logic   [NUMBER_SLAVE-1:0]      slv_valid,
    output  logic                           slv_invalid,

    input   logic                           m_axil_awvalid,
    input   logic                           m_axil_wvalid
);

    logic           [NUMBER_SLAVE-1:0]      slv_valid_wire;
    logic           [NUMBER_SLAVE-1:0]      slv_invalid_wire; 

    genvar i;

    always_ff @(posedge aclk)
    begin
       if (!aresetn)
       begin
           slv_valid <= '0;
           slv_invalid <= 0;
       end else
       begin
            if (m_axil_awvalid && m_axil_wvalid)
            begin
                slv_valid <= slv_valid_wire;
                slv_invalid <= slv_invalid_wire;
            end else
            begin
                slv_valid <= 0;
                slv_invalid <= 0;
            end
       end
    end

    generate
        for (i = 0; i < NUMBER_SLAVE; i++) begin : gen_slave
            assign slv_valid_wire[i] = (addr >= AXI_ADDR_OFFSET[i]) && (addr < (AXI_ADDR_OFFSET[i] + AXI_ADDR_RANGE[i]));
        end
    endgenerate

    assign slv_invalid_wire = ~|slv_valid_wire;

endmodule