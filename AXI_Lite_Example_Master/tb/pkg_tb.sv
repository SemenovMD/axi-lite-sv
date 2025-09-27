package pkg_tb;

    // Testbench parameters
    parameter int AXI_DATA_WIDTH = 32;
    parameter int AXI_ADDR_WIDTH = 32;
    parameter int CLOCK_PERIOD = 10; // 10ns = 100MHz

    // Test constants
    parameter int NUM_WRITE_TESTS = 5;
    parameter int NUM_READ_TESTS = 5;
    parameter int MAX_DELAY = 20;

    // Test addresses
    parameter logic [AXI_ADDR_WIDTH-1:0] TEST_ADDR_1 = 32'h0000_1000;
    parameter logic [AXI_ADDR_WIDTH-1:0] TEST_ADDR_2 = 32'h0000_2000;
    parameter logic [AXI_ADDR_WIDTH-1:0] TEST_ADDR_3 = 32'h0000_3000;
    parameter logic [AXI_ADDR_WIDTH-1:0] TEST_ADDR_4 = 32'h0000_4000;
    parameter logic [AXI_ADDR_WIDTH-1:0] TEST_ADDR_5 = 32'h0000_5000;

    // Test data
    parameter logic [AXI_DATA_WIDTH-1:0] TEST_DATA_1 = 32'hDEAD_BEEF;
    parameter logic [AXI_DATA_WIDTH-1:0] TEST_DATA_2 = 32'hCAFE_BABE;
    parameter logic [AXI_DATA_WIDTH-1:0] TEST_DATA_3 = 32'h1234_5678;
    parameter logic [AXI_DATA_WIDTH-1:0] TEST_DATA_4 = 32'h9ABC_DEF0;
    parameter logic [AXI_DATA_WIDTH-1:0] TEST_DATA_5 = 32'h5555_AAAA;

    // AXI-Lite response codes
    typedef enum logic [1:0] {
        AXI_OKAY   = 2'b00,
        AXI_EXOKAY = 2'b01,
        AXI_SLVERR = 2'b10,
        AXI_DECERR = 2'b11
    } axi_resp_t;

    // Test result structure
    typedef struct {
        logic [AXI_ADDR_WIDTH-1:0] addr;
        logic [AXI_DATA_WIDTH-1:0] data;
        axi_resp_t resp;
        logic success;
    } test_result_t;

endpackage
