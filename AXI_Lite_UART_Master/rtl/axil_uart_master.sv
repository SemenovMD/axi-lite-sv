module axil_uart_master

#(
    parameter   CLOCK           =   100_000_000,
    parameter   BAUD_RATE       =   115_200,
    parameter   UART_BYTE_START =   8'hF0,
    parameter   UART_BYTE_WR    =   8'hA1,
    parameter   UART_BYTE_RD    =   8'hA2
)

(
    input   logic                               aclk,
    input   logic                               aresetn,

    input   logic                               uart_rx,
    output  logic                               uart_tx,

	axil_if.m_axil                              m_axil
);

    localparam  AXI_DATA_WIDTH  =   32;
    localparam  AXI_ADDR_WIDTH  =   32;

    axis_if                         m_axis();
    axis_if                         s_axis();

    logic                           wr_valid;
    logic                           wr_ready;
    logic   [AXI_ADDR_WIDTH-1:0]    wr_addr;
    logic   [AXI_DATA_WIDTH-1:0]    wr_data;
    logic                           wr_done;
    logic   [1:0]                   wr_error;

    logic                           rd_valid;
    logic                           rd_ready;
    logic   [AXI_ADDR_WIDTH-1:0]    rd_addr;
    logic   [AXI_DATA_WIDTH-1:0]    rd_data;
    logic                           rd_done;
    logic   [1:0]                   rd_error;

    axis_uart #(.CLOCK(CLOCK), .BAUD_RATE(BAUD_RATE)) axis_uart_inst
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .m_axis(m_axis),
        .s_axis(s_axis)
    );

    axis_uart_parser_gen #(.UART_BYTE_START(UART_BYTE_START), .UART_BYTE_WR(UART_BYTE_WR), .UART_BYTE_RD(UART_BYTE_RD)) axis_uart_parser_gen_inst
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
        .m_axis(s_axis),
        .s_axis(m_axis)
    );

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