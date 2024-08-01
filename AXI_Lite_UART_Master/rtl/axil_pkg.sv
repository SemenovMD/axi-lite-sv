package axil_pkg;

    parameter                               AXI_DATA_WIDTH                  = 32;
    parameter                               AXI_ADDR_WIDTH                  = 32;


    // UART
    parameter                               AXI_DATA_WIDTH_UART             = 72;

    parameter                               CLOCK                           = 100_000_000;
    parameter                               BAUD_RATE                       = 115_200;
    parameter                               DATA_BITS                       = 72;
    parameter                               STOP_BITS                       = 1;
    parameter                               PARITY_BITS                     = 0;

    parameter                               UART_MASTER_CODE_WR             = 5'b11100;
    parameter                               UART_MASTER_CODE_RD             = 5'b10101;

endpackage