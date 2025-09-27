module axil_wrapper_v 

#(
    parameter   AXI_DATA_WIDTH  =   32,
    parameter   AXI_ADDR_WIDTH  =   32
)

(
    // Global Signals
    input   wire                            aclk,
    input   wire                            aresetn,

    // Interface Write
    input   wire                            wr_valid,
    output  wire                            wr_ready,
    input   wire    [AXI_ADDR_WIDTH-1:0]    wr_addr,
    input   wire    [AXI_DATA_WIDTH-1:0]    wr_data,
    output  wire                            wr_done,
    output  wire    [1:0]                   wr_error,

    // Interface Read
    input   wire                            rd_valid,
    output  wire                            rd_ready,
    input   wire    [AXI_ADDR_WIDTH-1:0]    rd_addr,
    output  wire    [AXI_DATA_WIDTH-1:0]    rd_data,
    output  wire                            rd_done,
    output  wire    [1:0]                   rd_error,

    // Interface AXI-Lite Master
    output  wire    [AXI_ADDR_WIDTH-1:0]    m_axil_awaddr,
    output  wire                            m_axil_awvalid,
    input   wire                            m_axil_awready,

    output  wire    [AXI_DATA_WIDTH-1:0]    m_axil_wdata,
    output  wire    [AXI_DATA_WIDTH/8-1:0]  m_axil_wstrb,
    output  wire                            m_axil_wvalid,
    input   wire                            m_axil_wready,

    input   wire    [1:0]                   m_axil_bresp,
    input   wire                            m_axil_bvalid,
    output  wire                            m_axil_bready,

    output  wire    [AXI_ADDR_WIDTH-1:0]    m_axil_araddr,
    output  wire                            m_axil_arvalid,
    input   wire                            m_axil_arready,

    input   wire    [AXI_DATA_WIDTH-1:0]    m_axil_rdata,
    input   wire    [1:0]                   m_axil_rresp,
    input   wire                            m_axil_rvalid,
    output  wire                            m_axil_rready
);

    ////////////////////////////////////////////////////////////////////////////////////
    // Instantiate SystemVerilog wrapper
    ////////////////////////////////////////////////////////////////////////////////////

    axil_master_wrapper_sv #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH), .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)) axil_master_wrapper_sv_inst
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
        
        .m_axil_awaddr(m_axil_awaddr),
        .m_axil_awvalid(m_axil_awvalid),
        .m_axil_awready(m_axil_awready),
        
        .m_axil_wdata(m_axil_wdata),
        .m_axil_wstrb(m_axil_wstrb),
        .m_axil_wvalid(m_axil_wvalid),
        .m_axil_wready(m_axil_wready),
        
        .m_axil_bresp(m_axil_bresp),
        .m_axil_bvalid(m_axil_bvalid),
        .m_axil_bready(m_axil_bready),
        
        .m_axil_araddr(m_axil_araddr),
        .m_axil_arvalid(m_axil_arvalid),
        .m_axil_arready(m_axil_arready),
        
        .m_axil_rdata(m_axil_rdata),
        .m_axil_rresp(m_axil_rresp),
        .m_axil_rvalid(m_axil_rvalid),
        .m_axil_rready(m_axil_rready)
    );

endmodule