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

    parameter   bit [AXI_ADDR_WIDTH-1:0]    AXI_ADDR_RANGE  [NUMBER_SLAVE]  = '{32'h0FFF_FFFF, 
                                                                                32'h0FFF_FFFF, 
                                                                                32'h0FFF_FFFF, 
                                                                                32'h0FFF_FFFF,
                                                                                32'h0FFF_FFFF, 
                                                                                32'h0FFF_FFFF, 
                                                                                32'h0FFF_FFFF, 
                                                                                32'h0FFF_FFFF,
                                                                                32'h0FFF_FFFF, 
                                                                                32'h0FFF_FFFF, 
                                                                                32'h0FFF_FFFF, 
                                                                                32'h0FFF_FFFF,
                                                                                32'h0FFF_FFFF,
                                                                                32'h0FFF_FFFF,
                                                                                32'h0FFF_FFFF,
                                                                                32'h0FFF_FFFF}
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

    genvar i;

    logic   [AXI_ADDR_WIDTH-1:0]        s_axil_awaddr_1           [NUMBER_SLAVE+1];
    logic   [NUMBER_SLAVE:0]          s_axil_awvalid_1;
    logic   [NUMBER_SLAVE:0]          s_axil_awready_1;

    logic   [AXI_ADDR_WIDTH-1:0]        s_axil_wdata_1            [NUMBER_SLAVE+1];
    logic   [AXI_DATA_WIDTH/8-1:0]      s_axil_wstrb_1            [NUMBER_SLAVE+1];
    logic   [NUMBER_SLAVE:0]          s_axil_wvalid_1;
    logic   [NUMBER_SLAVE:0]          s_axil_wready_1;

    logic   [1:0]                       s_axil_bresp_1            [NUMBER_SLAVE+1];
    logic   [NUMBER_SLAVE:0]          s_axil_bvalid_1;
    logic   [NUMBER_SLAVE:0]          s_axil_bready_1;

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
        .s_axil_awaddr(s_axil_awaddr_1),
        .s_axil_awvalid(s_axil_awvalid_1),
        .s_axil_awready(s_axil_awready_1),
        .s_axil_wdata(s_axil_wdata_1),
        .s_axil_wstrb(s_axil_wstrb_1),
        .s_axil_wvalid(s_axil_wvalid_1),
        .s_axil_wready(s_axil_wready_1),
        .s_axil_bresp(s_axil_bresp_1),
        .s_axil_bvalid(s_axil_bvalid_1),
        .s_axil_bready(s_axil_bready_1),
        .*
    );

    generate
        for (i = 0; i < NUMBER_SLAVE; i++) begin : gen_slave
            assign s_axil_awaddr[i]      =   s_axil_awaddr_1[i];
            assign s_axil_awvalid[i]     =   s_axil_awvalid_1[i];
            assign s_axil_awready_1[i]   =   s_axil_awready[i];
            
            assign s_axil_wdata[i]       =   s_axil_wdata_1[i];
            assign s_axil_wstrb[i]       =   s_axil_wstrb_1[i];
            assign s_axil_wvalid[i]      =   s_axil_wvalid_1[i];
            assign s_axil_wready_1[i]        =   s_axil_wready[i];

            assign s_axil_bresp_1[i]         =   s_axil_bresp[i];
            assign s_axil_bvalid_1[i]        =   s_axil_bvalid[i];
            assign s_axil_bready[i]      =   s_axil_bready_1[i];
        end
    endgenerate

    axil_response_addr_invalid_wr #(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
    )

    axil_response_addr_invalid_wr_inst
    
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axil_awaddr(s_axil_awaddr_1[NUMBER_SLAVE]),
        .s_axil_awvalid(s_axil_awvalid_1[NUMBER_SLAVE]),
        .s_axil_wdata(s_axil_wvalid_1[NUMBER_SLAVE]),
        .s_axil_wstrb(s_axil_wstrb_1[NUMBER_SLAVE]),
        .s_axil_wvalid(s_axil_wvalid_1[NUMBER_SLAVE]),
        .s_axil_awready(s_axil_awready_1[NUMBER_SLAVE]),
        .s_axil_wready(s_axil_wready_1[NUMBER_SLAVE]),
        .s_axil_bresp(s_axil_bresp_1[NUMBER_SLAVE]),
        .s_axil_bvalid(s_axil_bvalid_1[NUMBER_SLAVE]),
        .s_axil_bready(s_axil_bready_1[NUMBER_SLAVE])
    );


endmodule
