package pkg_tb;

    parameter                               NUMBER_MASTER                   = 32;
    parameter                               NUMBER_SLAVE                    = 16;
    parameter                               AXI_DATA_WIDTH                  = 32;
    parameter                               AXI_ADDR_WIDTH                  = 32;

    parameter   bit [AXI_ADDR_WIDTH-1:0]    AXI_ADDR_OFFSET [NUMBER_SLAVE]  = '{32'h0000_0000, 
                                                                                32'h1000_0000, 
                                                                                32'h2000_0000, 
                                                                                32'h3000_0000,
                                                                                32'h4000_0000, 
                                                                                32'h5000_0000, 
                                                                                32'h6000_0000, 
                                                                                32'h7000_0000,
                                                                                32'h8000_0000, 
                                                                                32'h9000_0000, 
                                                                                32'hA000_0000, 
                                                                                32'hB000_0000,
                                                                                32'hC000_0000, 
                                                                                32'hD000_0000, 
                                                                                32'hE000_0000, 
                                                                                32'hF000_0000};

    parameter   bit [AXI_ADDR_WIDTH-1:0]    AXI_ADDR_RANGE  [NUMBER_SLAVE]  = '{32'h0000_FFFF, 
                                                                                32'h0000_FFFF, 
                                                                                32'h0000_FFFF, 
                                                                                32'h0000_FFFF,
                                                                                32'h0000_FFFF, 
                                                                                32'h0000_FFFF, 
                                                                                32'h0000_FFFF, 
                                                                                32'h0000_FFFF,
                                                                                32'h0000_FFFF, 
                                                                                32'h0000_FFFF, 
                                                                                32'h0000_FFFF, 
                                                                                32'h0000_FFFF,
                                                                                32'h0000_FFFF,
                                                                                32'h0000_FFFF,
                                                                                32'h0000_FFFF,
                                                                                32'h0000_FFFF};

    parameter AXI_TRAN_MIN_DELAY = 2;
    parameter AXI_TRAN_MAX_DELAY = 17;
    //parameter AXI_TRAN_MAX_WAIT = 150;

endpackage