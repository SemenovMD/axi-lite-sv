module axil_decoder_addr_rd
#(
    parameter                               NUMBER_SLAVE                    =   4,
    parameter                               AXI_ADDR_WIDTH                  =   32,
    parameter   bit [AXI_ADDR_WIDTH-1:0]    AXI_ADDR_OFFSET [NUMBER_SLAVE]  =   '{default: '0},
    parameter   bit [AXI_ADDR_WIDTH-1:0]    AXI_ADDR_RANGE  [NUMBER_SLAVE]  =   '{default: 1}
)

(
    input   logic   [AXI_ADDR_WIDTH-1:0]    addr,
    output  logic   [NUMBER_SLAVE-1:0]      slv_select,
    output  logic                           addr_illegal,

    input   logic                           m_axil_arvalid
);
    genvar i;

    generate
        for (i = 0; i < NUMBER_SLAVE; i++) begin : addr_region_range
            assign slv_select[i] = m_axil_arvalid && (addr >=  AXI_ADDR_OFFSET[i]) && (addr <  (AXI_ADDR_OFFSET[i] + AXI_ADDR_RANGE[i]));
        end
    endgenerate

    assign addr_illegal = ~|(slv_select);

endmodule