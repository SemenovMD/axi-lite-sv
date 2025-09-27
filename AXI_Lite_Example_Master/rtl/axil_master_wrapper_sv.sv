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

    assign m_axil.awaddr  = m_axil_awaddr;
    assign m_axil.awvalid = m_axil_awvalid;
    assign m_axil_awready = m_axil.awready;
    
    assign m_axil.wdata   = m_axil_wdata;
    assign m_axil.wstrb   = m_axil_wstrb;
    assign m_axil.wvalid  = m_axil_wvalid;
    assign m_axil_wready  = m_axil.wready;
    
    assign m_axil_bresp   = m_axil.bresp;
    assign m_axil_bvalid  = m_axil.bvalid;
    assign m_axil.bready  = m_axil.bready;
    
    assign m_axil.araddr  = m_axil_araddr;
    assign m_axil.arvalid = m_axil_arvalid;
    assign m_axil_arready = m_axil.arready;
    
    assign m_axil_rdata   = m_axil.rdata;
    assign m_axil_rresp   = m_axil.rresp;
    assign m_axil_rvalid  = m_axil.rvalid;
    assign m_axil.rready  = m_axil.rready;

    axil_master axil_master_inst
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
