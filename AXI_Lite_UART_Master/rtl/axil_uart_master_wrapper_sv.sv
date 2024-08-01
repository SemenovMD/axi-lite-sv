module axil_uart_master_wrapper_sv

    import axil_pkg ::*;

(
    input   logic                       aclk,
    input   logic                       aresetn,

    input   logic                       uart_rx,
    output  logic                       uart_tx,

    axil_if.m_axil                      m_axil
);

    axis_if_uart                        s_axis();
    axis_if_uart                        m_axis();

    axil_uart_master axil_uart_master_inst

    (
        .aclk(aclk),
        .aresetn(aresetn),
        .m_axis(s_axis),
        .s_axis(m_axis),
        .m_axil(m_axil)
    );

    axis_uart_transceiver axis_uart_transceiver

    (
        .aclk(aclk),
        .aresetn(aresetn),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .m_axis(m_axis),
        .s_axis(s_axis)
    );

endmodule