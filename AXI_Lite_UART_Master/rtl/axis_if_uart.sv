interface axis_if_uart;

    import axil_pkg ::*;

    logic   [AXI_DATA_WIDTH_UART-1:0]   tdata;
    logic                               tvalid;
    logic                               tready;

    modport m_axis
    (
        output tdata,
        output tvalid,
        input  tready
    );

    modport s_axis
    (
        input  tdata,
        input  tvalid,
        output tready
    );

endinterface
