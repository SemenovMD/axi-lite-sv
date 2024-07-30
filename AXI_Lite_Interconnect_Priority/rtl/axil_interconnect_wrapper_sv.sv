module axil_interconnect_wrapper_sv
#(
    parameter                               NUMBER_MASTER                   = 32,
    parameter                               NUMBER_SLAVE                    = 16,
    parameter                               AXI_DATA_WIDTH                  = 32,
    parameter                               AXI_ADDR_WIDTH                  = 32,

    parameter   bit [AXI_ADDR_WIDTH-1:0]    AXI_ADDR_OFFSET [NUMBER_SLAVE]  = '{32'h0000_0000,
                                                                                32'h1000_0000, 
                                                                                32'h2000_0000, 
                                                                                32'h3000_0000,
                                                                                32'h4000_0000, 
                                                                                32'h5000_0000, 
                                                                                32'h6000_0000, 
                                                                                32'h7000_0000,
                                                                                32'h8000_0000, 
                                                                                32'h9000_0000, 
                                                                                32'hA000_0000, 
                                                                                32'hB000_0000,
                                                                                32'hC000_0000, 
                                                                                32'hD000_0000, 
                                                                                32'hE000_0000, 
                                                                                32'hF000_0000},

    parameter   bit [AXI_ADDR_WIDTH-1:0]    AXI_ADDR_RANGE  [NUMBER_SLAVE]  = '{32'h00FF_FFFF,
                                                                                32'h00FF_FFFF, 
                                                                                32'h00FF_FFFF, 
                                                                                32'h00FF_FFFF,
                                                                                32'h00FF_FFFF, 
                                                                                32'h00FF_FFFF, 
                                                                                32'h00FF_FFFF, 
                                                                                32'h00FF_FFFF,
                                                                                32'h00FF_FFFF, 
                                                                                32'h00FF_FFFF, 
                                                                                32'h00FF_FFFF, 
                                                                                32'h00FF_FFFF,
                                                                                32'h00FF_FFFF,
                                                                                32'h00FF_FFFF,
                                                                                32'h00FF_FFFF,
                                                                                32'h00FF_FFFF}
)

(
    input   logic                               aclk,
    input   logic                               aresetn,

    // Interface
    axil_if.m_axil                              m_axil              [NUMBER_SLAVE],
    axil_if.s_axil                              s_axil              [NUMBER_MASTER]
);

    axil_interconnect #

    (
        .NUMBER_MASTER(NUMBER_MASTER),
        .NUMBER_SLAVE(NUMBER_SLAVE),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_ADDR_OFFSET(AXI_ADDR_OFFSET),
        .AXI_ADDR_RANGE(AXI_ADDR_RANGE)
    )

    axil_interconnect_inst

    (
        .*
    );

endmodule