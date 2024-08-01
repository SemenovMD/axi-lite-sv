module axis_uart_transceiver

    import axil_pkg ::*;

(
    // Global signals
    input   logic                               aclk,
    input   logic                               aresetn,

    // Transmitter
    input   logic                               uart_rx,
    output  logic                               uart_tx,

    // Flag State
    output  logic                               tx_done,
    output  logic                               rx_done,
    output  logic [1:0]                         rx_error,

    // Interface
    axis_if_uart.m_axis                         m_axis,
    axis_if_uart.s_axis                         s_axis
);

    axis_uart_tx axis_uart_tx_inst

    (
        .*
    );

    axis_uart_rx axis_uart_rx_inst

    (
        .*
    );

endmodule