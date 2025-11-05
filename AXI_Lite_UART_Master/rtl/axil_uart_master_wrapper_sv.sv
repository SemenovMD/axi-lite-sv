module axil_uart_master_wrapper_sv

#(
    parameter   CLOCK           =   100_000_000,
    parameter   BAUD_RATE       =   115_200,
    parameter   UART_BYTE_START =   8'hF0,
    parameter   UART_BYTE_WR    =   8'hA1,
    parameter   UART_BYTE_RD    =   8'hA2
)

(
    // Global Signals
    input   logic                           aclk,
    input   logic                           aresetn,

    // Interface UART
    input   logic                           uart_rx,
    output  logic                           uart_tx,

    // Interface AXI-Lite Master
    output  logic   [31:0]                  m_axil_awaddr,
    output  logic                           m_axil_awvalid,
    input   logic                           m_axil_awready,

    output  logic   [31:0]                  m_axil_wdata,
    output  logic   [3:0]                   m_axil_wstrb,
    output  logic                           m_axil_wvalid,
    input   logic                           m_axil_wready,

    input   logic   [1:0]                   m_axil_bresp,
    input   logic                           m_axil_bvalid,
    output  logic                           m_axil_bready,

    output  logic   [31:0]                  m_axil_araddr,
    output  logic                           m_axil_arvalid,
    input   logic                           m_axil_arready,

    input   logic   [31:0]                  m_axil_rdata,
    input   logic   [1:0]                   m_axil_rresp,
    input   logic                           m_axil_rvalid,
    output  logic                           m_axil_rready
);

    localparam  AXI_DATA_WIDTH  =   32;
    localparam  AXI_ADDR_WIDTH  =   32;

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

    axil_uart_master #(
        .CLOCK(CLOCK), 
        .BAUD_RATE(BAUD_RATE), 
        .UART_BYTE_START(UART_BYTE_START),
        .UART_BYTE_WR(UART_BYTE_WR),
        .UART_BYTE_RD(UART_BYTE_RD)
    )

    axil_uart_master_inst
    
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .m_axil(m_axil)
    );

endmodule
