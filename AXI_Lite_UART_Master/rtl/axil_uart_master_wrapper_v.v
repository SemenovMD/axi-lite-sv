module axil_uart_master_wrapper_v 

#(
    parameter   CLOCK           =   100_000_000,
    parameter   BAUD_RATE       =   115_200,
    parameter   UART_BYTE_START =   8'hF0,
    parameter   UART_BYTE_WR    =   8'hA1,
    parameter   UART_BYTE_RD    =   8'hA2
)

(
    // Global Signals
    input   wire                            aclk,
    input   wire                            aresetn,

    // Interface UART
    input   wire                            uart_rx,
    output  wire                            uart_tx,

    // Interface AXI-Lite Master
    output  wire   [31:0]                   m_axil_awaddr,
    output  wire                            m_axil_awvalid,
    input   wire                            m_axil_awready,

    output  wire   [31:0]                   m_axil_wdata,
    output  wire   [3:0]                    m_axil_wstrb,
    output  wire                            m_axil_wvalid,
    input   wire                            m_axil_wready,

    input   wire   [1:0]                    m_axil_bresp,
    input   wire                            m_axil_bvalid,
    output  wire                            m_axil_bready,

    output  wire   [31:0]                   m_axil_araddr,
    output  wire                            m_axil_arvalid,
    input   wire                            m_axil_arready,

    input   wire   [31:0]                   m_axil_rdata,
    input   wire   [1:0]                    m_axil_rresp,
    input   wire                            m_axil_rvalid,
    output  wire                            m_axil_rready
);

    ////////////////////////////////////////////////////////////////////////////////////
    // Instantiate SystemVerilog wrapper
    ////////////////////////////////////////////////////////////////////////////////////

    axil_uart_master_wrapper_sv #(
        .CLOCK(CLOCK), 
        .BAUD_RATE(BAUD_RATE), 
        .UART_BYTE_START(UART_BYTE_START),
        .UART_BYTE_WR(UART_BYTE_WR),
        .UART_BYTE_RD(UART_BYTE_RD)
    ) 

    axil_uart_master_wrapper_sv_inst
    
    (
        .aclk(aclk),
        .aresetn(aresetn),
        
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        
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