module axil_interconnect_wrapper_sv
    
    import axil_pkg ::*;

(
    // Global Signals
    input   logic                               aclk,
    input   logic                               aresetn,

    // Interface
    axil_if.m_axil                              m_axil              [NUMBER_SLAVE],
    axil_if.s_axil                              s_axil              [NUMBER_MASTER]
);

    ////////////////////////////////////////////////////////////////////////////////////
    // Interconnect AXI-Lite
    ////////////////////////////////////////////////////////////////////////////////////

    axil_interconnect axil_interconnect_inst
    (
        .*
    );

endmodule