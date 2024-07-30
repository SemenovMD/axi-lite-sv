module axil_interconnect
#(
    parameter                               NUMBER_MASTER                   = 1,
    parameter                               NUMBER_SLAVE                    = 16,
    parameter                               AXI_DATA_WIDTH                  = 32,
    parameter                               AXI_ADDR_WIDTH                  = 32,

    parameter   bit [AXI_ADDR_WIDTH-1:0]    AXI_ADDR_OFFSET [NUMBER_SLAVE]  = '{default: '0},
    parameter   bit [AXI_ADDR_WIDTH-1:0]    AXI_ADDR_RANGE  [NUMBER_SLAVE]  = '{default: 1}
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
    logic   [NUMBER_SLAVE:0]            s_axil_awvalid_1;
    logic   [NUMBER_SLAVE:0]            s_axil_awready_1;

    logic   [AXI_ADDR_WIDTH-1:0]        s_axil_wdata_1            [NUMBER_SLAVE+1];
    logic   [AXI_DATA_WIDTH/8-1:0]      s_axil_wstrb_1            [NUMBER_SLAVE+1];
    logic   [NUMBER_SLAVE:0]            s_axil_wvalid_1;
    logic   [NUMBER_SLAVE:0]            s_axil_wready_1;

    logic   [1:0]                       s_axil_bresp_1            [NUMBER_SLAVE+1];
    logic   [NUMBER_SLAVE:0]            s_axil_bvalid_1;
    logic   [NUMBER_SLAVE:0]            s_axil_bready_1;



    logic   [AXI_ADDR_WIDTH-1:0]        s_axil_araddr_1           [NUMBER_SLAVE+1];
    logic   [NUMBER_SLAVE:0]            s_axil_arvalid_1;
    logic   [NUMBER_SLAVE:0]            s_axil_arready_1;

    logic   [AXI_ADDR_WIDTH-1:0]        s_axil_rdata_1            [NUMBER_SLAVE+1];
    logic   [1:0]                       s_axil_rresp_1            [NUMBER_SLAVE+1];
    logic   [NUMBER_SLAVE:0]            s_axil_rvalid_1;
    logic   [NUMBER_SLAVE:0]            s_axil_rready_1;

    axil_interconnect_wr #

    (
        .NUMBER_MASTER(NUMBER_MASTER),
        .NUMBER_SLAVE(NUMBER_SLAVE),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_ADDR_OFFSET(AXI_ADDR_OFFSET),
        .AXI_ADDR_RANGE(AXI_ADDR_RANGE)
    )

    axil_interconnect_wr_inst

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
        for (i = 0; i < NUMBER_SLAVE; i++) begin : gen_slave_wr
            assign s_axil_awaddr[i]      =   s_axil_awaddr_1[i];
            assign s_axil_awvalid[i]     =   s_axil_awvalid_1[i];
            assign s_axil_awready_1[i]   =   s_axil_awready[i];
            
            assign s_axil_wdata[i]       =   s_axil_wdata_1[i];
            assign s_axil_wstrb[i]       =   s_axil_wstrb_1[i];
            assign s_axil_wvalid[i]      =   s_axil_wvalid_1[i];
            assign s_axil_wready_1[i]    =   s_axil_wready[i];

            assign s_axil_bresp_1[i]     =   s_axil_bresp[i];
            assign s_axil_bvalid_1[i]    =   s_axil_bvalid[i];
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

    ///////////////////////////////////////////////////////////////////////////

    axil_interconnect_rd #

    (
        .NUMBER_MASTER(NUMBER_MASTER),
        .NUMBER_SLAVE(NUMBER_SLAVE),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_ADDR_OFFSET(AXI_ADDR_OFFSET),
        .AXI_ADDR_RANGE(AXI_ADDR_RANGE)
    )

    axil_interconnect_rd_inst

    (
        .s_axil_araddr(s_axil_araddr_1),
        .s_axil_arvalid(s_axil_arvalid_1),
        .s_axil_arready(s_axil_arready_1),
        .s_axil_rdata(s_axil_rdata_1),
        .s_axil_rresp(s_axil_rresp_1),
        .s_axil_rvalid(s_axil_rvalid_1),
        .s_axil_rready(s_axil_rready_1),
        .*
    );

    generate
        for (i = 0; i < NUMBER_SLAVE; i++) begin : gen_slave_rd
            assign s_axil_araddr[i]         =   s_axil_araddr_1[i];
            assign s_axil_arvalid[i]        =   s_axil_arvalid_1[i];
            assign s_axil_arready_1[i]      =   s_axil_arready[i];
            
            assign s_axil_rdata_1[i]        =   s_axil_rdata[i];
            assign s_axil_rresp_1[i]        =   s_axil_rresp[i];
            assign s_axil_rvalid_1[i]       =   s_axil_rvalid[i];
            assign s_axil_rready[i]         =   s_axil_rready_1[i];
        end
    endgenerate

    axil_response_addr_invalid_rd #(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
    )

    axil_response_addr_invalid_rd_inst
    
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axil_araddr(s_axil_araddr_1[NUMBER_SLAVE]),
        .s_axil_arvalid(s_axil_arvalid_1[NUMBER_SLAVE]),
        .s_axil_arready(s_axil_arready_1[NUMBER_SLAVE]),
        .s_axil_rdata(s_axil_rdata_1[NUMBER_SLAVE]),
        .s_axil_rresp(s_axil_rresp_1[NUMBER_SLAVE]),
        .s_axil_rvalid(s_axil_rvalid_1[NUMBER_SLAVE]),
        .s_axil_rready(s_axil_rready_1[NUMBER_SLAVE])
    );

endmodule