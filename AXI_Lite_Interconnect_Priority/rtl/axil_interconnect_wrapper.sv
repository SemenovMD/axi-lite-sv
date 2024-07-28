module axil_interconnect_wrapper
#(
    parameter                               NUMBER_MASTER                   = 20,
    parameter                               NUMBER_SLAVE                    = 12,
    parameter                               AXI_DATA_WIDTH                  = 32,
    parameter                               AXI_ADDR_WIDTH                  = 32,
    parameter   bit [AXI_ADDR_WIDTH-1:0]    AXI_ADDR_OFFSET [NUMBER_SLAVE]  = '{32'h1000_0000, 32'h2000_0000, 32'h3000_0000, 32'h4000_0000,
                                                                                32'h5000_0000, 32'h6000_0000, 32'h7000_0000, 32'h8000_0000,
                                                                                32'h9000_0000, 32'hA000_0000, 32'hB000_0000, 32'hC000_0000},
    parameter   bit [AXI_ADDR_WIDTH-1:0]    AXI_ADDR_RANGE  [NUMBER_SLAVE]  = '{32'h0000_FFFF, 32'h0000_FFFF, 32'h0000_FFFF, 32'h0000_FFFF,
                                                                                32'h0000_FFFF, 32'h0000_FFFF, 32'h0000_FFFF, 32'h0000_FFFF,
                                                                                32'h0000_FFFF, 32'h0000_FFFF, 32'h0000_FFFF, 32'h0000_FFFF}
)

(
    input   logic                               aclk,
    input   logic                               aresetn,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel WRITE Master
    ////////////////////////////////////////////////////////////////////////////////////////////////

    // Channel Write Address
    input   logic   [AXI_ADDR_WIDTH-1:0]        m_axil_awaddr           [NUMBER_MASTER],
    input   logic   [NUMBER_MASTER-1:0]         m_axil_awvalid,
    output  logic   [NUMBER_MASTER-1:0]         m_axil_awready,

    // Channel Write Data
    input   logic   [AXI_ADDR_WIDTH-1:0]        m_axil_wdata            [NUMBER_MASTER],
    input   logic   [AXI_DATA_WIDTH/8-1:0]      m_axil_wstrb            [NUMBER_MASTER],
    input   logic   [NUMBER_MASTER-1:0]         m_axil_wvalid,
    output  logic   [NUMBER_MASTER-1:0]         m_axil_wready,

    // Channel Write Response
    output  logic   [1:0]                       m_axil_bresp            [NUMBER_MASTER],
    output  logic   [NUMBER_MASTER-1:0]         m_axil_bvalid,
    input   logic   [NUMBER_MASTER-1:0]         m_axil_bready,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel WRITE Slave
    ////////////////////////////////////////////////////////////////////////////////////////////////

    // Channel Write Address
    output  logic   [AXI_ADDR_WIDTH-1:0]        s_axil_awaddr           [NUMBER_SLAVE],
    output  logic   [NUMBER_SLAVE-1:0]          s_axil_awvalid,
    input   logic   [NUMBER_SLAVE-1:0]          s_axil_awready,

    // Channel Write Data
    output  logic   [AXI_ADDR_WIDTH-1:0]        s_axil_wdata            [NUMBER_SLAVE],
    output  logic   [AXI_DATA_WIDTH/8-1:0]      s_axil_wstrb            [NUMBER_SLAVE],
    output  logic   [NUMBER_SLAVE-1:0]          s_axil_wvalid,
    input   logic   [NUMBER_SLAVE-1:0]          s_axil_wready,

    // Channel Write Response
    input   logic   [1:0]                       s_axil_bresp            [NUMBER_SLAVE],
    input   logic   [NUMBER_SLAVE-1:0]          s_axil_bvalid,
    output  logic   [NUMBER_SLAVE-1:0]          s_axil_bready,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel READ Master
    ////////////////////////////////////////////////////////////////////////////////////////////////

    // Channel Read Address
    input   logic   [AXI_ADDR_WIDTH-1:0]        m_axil_araddr           [NUMBER_MASTER],
    input   logic   [NUMBER_MASTER-1:0]         m_axil_arvalid,
    output  logic   [NUMBER_MASTER-1:0]         m_axil_arready,

    // Channel Read Data
    output  logic   [AXI_DATA_WIDTH-1:0]        m_axil_rdata            [NUMBER_MASTER],
    output  logic   [1:0]                       m_axil_rresp            [NUMBER_MASTER],
    output  logic   [NUMBER_MASTER-1:0]         m_axil_rvalid,
    input   logic   [NUMBER_MASTER-1:0]         m_axil_rready,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel READ Slave
    ////////////////////////////////////////////////////////////////////////////////////////////////

    // Channel Read Address
    output  logic   [AXI_ADDR_WIDTH-1:0]        s_axil_araddr           [NUMBER_SLAVE],
    output  logic   [NUMBER_SLAVE-1:0]          s_axil_arvalid,
    input   logic   [NUMBER_SLAVE-1:0]          s_axil_arready,

    // Channel Read Data
    input   logic   [AXI_DATA_WIDTH-1:0]        s_axil_rdata            [NUMBER_SLAVE],
    input   logic   [1:0]                       s_axil_rresp            [NUMBER_SLAVE],
    input   logic   [NUMBER_SLAVE-1:0]          s_axil_rvalid,
    output  logic   [NUMBER_SLAVE-1:0]          s_axil_rready
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

