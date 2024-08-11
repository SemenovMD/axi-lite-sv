package axil_pkg;

    // AXI-Lite Master
    parameter                               AXI_DATA_WIDTH                  = 32;
    parameter                               AXI_ADDR_WIDTH                  = 32;


    // UART
    parameter                               AXI_DATA_WIDTH_UART             = 72;

    parameter                               CLOCK                           = 25_000_000;
    parameter                               BAUD_RATE                       = 115_200;

    parameter                               UART_MASTER_CODE_WR             = 4'hA;
    parameter                               UART_MASTER_CODE_RD             = 4'hB;
    parameter                               HEADER_UART                     = 8'hF0;

endpackage