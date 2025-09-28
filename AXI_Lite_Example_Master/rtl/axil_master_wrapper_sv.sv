module axil_master_wrapper_sv

#(
    parameter   AXI_DATA_WIDTH  =   32,
    parameter   AXI_ADDR_WIDTH  =   32
)

(
    // Global Signals
    input   logic                           aclk,
    input   logic                           aresetn,

    // Interface Write
    input   logic                           wr_valid,
    output  logic                           wr_ready,
    input   logic   [AXI_ADDR_WIDTH-1:0]    wr_addr,
    input   logic   [AXI_DATA_WIDTH-1:0]    wr_data,
    output  logic                           wr_done,
    output  logic   [1:0]                   wr_error,

    // Interface Read
    input   logic                           rd_valid,
    output  logic                           rd_ready,
    input   logic   [AXI_ADDR_WIDTH-1:0]    rd_addr,
    output  logic   [AXI_DATA_WIDTH-1:0]    rd_data,
    output  logic                           rd_done,
    output  logic   [1:0]                   rd_error,

    // Interface AXI-Lite Master
    output  logic   [AXI_ADDR_WIDTH-1:0]    m_axil_awaddr,
    output  logic                           m_axil_awvalid,
    input   logic                           m_axil_awready,

    output  logic   [AXI_DATA_WIDTH-1:0]    m_axil_wdata,
    output  logic   [AXI_DATA_WIDTH/8-1:0]  m_axil_wstrb,
    output  logic                           m_axil_wvalid,
    input   logic                           m_axil_wready,

    input   logic   [1:0]                   m_axil_bresp,
    input   logic                           m_axil_bvalid,
    output  logic                           m_axil_bready,

    output  logic   [AXI_ADDR_WIDTH-1:0]    m_axil_araddr,
    output  logic                           m_axil_arvalid,
    input   logic                           m_axil_arready,

    input   logic   [AXI_DATA_WIDTH-1:0]    m_axil_rdata,
    input   logic   [1:0]                   m_axil_rresp,
    input   logic                           m_axil_rvalid,
    output  logic                           m_axil_rready
);

    axil_if #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH), .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)) m_axil();

    generate 
        assign m_axil_awaddr  = m_axil.awaddr;
        assign m_axil_awvalid = m_axil.awvalid;
        assign m_axil.awready = m_axil_awready;
        
        assign m_axil_wdata   = m_axil.wdata;
        assign m_axil_wstrb   = m_axil.wstrb;
        assign m_axil_wvalid  = m_axil.wvalid;
        assign m_axil.wready  = m_axil_wready;
        
        assign m_axil.bresp   = m_axil_bresp;
        assign m_axil.bvalid  = m_axil_bvalid;
        assign m_axil_bready  = m_axil.bready;
        
        assign m_axil_araddr  = m_axil.araddr;
        assign m_axil_arvalid = m_axil.arvalid;
        assign m_axil.arready = m_axil_arready;
        
        assign m_axil.rdata   = m_axil_rdata;
        assign m_axil.rresp   = m_axil_rresp;
        assign m_axil.rvalid  = m_axil_rvalid;
        assign m_axil_rready  = m_axil.rready;
    endgenerate

    axil_master #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH), .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)) axil_master_inst
    (
        .aclk(aclk),
        .aresetn(aresetn),
        
        .wr_valid(wr_valid),
        .wr_ready(wr_ready),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .wr_done(wr_done),
        .wr_error(wr_error),
        
        .rd_valid(rd_valid),
        .rd_ready(rd_ready),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .rd_done(rd_done),
        .rd_error(rd_error),
        
        .m_axil(m_axil)
    );

endmodule
