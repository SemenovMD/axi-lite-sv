module axil_master_tb;

    import pkg_tb::*;

    // Clock and Reset
    logic                           aclk;
    logic                           aresetn;

    // User Interface - Write
    logic                           wr_valid;
    logic                           wr_ready;
    logic   [AXI_ADDR_WIDTH-1:0]    wr_addr;
    logic   [AXI_DATA_WIDTH-1:0]    wr_data;
    logic                           wr_done;
    logic   [1:0]                   wr_error;

    // User Interface - Read
    logic                           rd_valid;
    logic                           rd_ready;
    logic   [AXI_ADDR_WIDTH-1:0]    rd_addr;
    logic   [AXI_DATA_WIDTH-1:0]    rd_data;
    logic                           rd_done;
    logic   [1:0]                   rd_error;

    // AXI-Lite Slave Interface - Write Address
    logic   [AXI_ADDR_WIDTH-1:0]    s_axil_awaddr;
    logic                           s_axil_awvalid;
    logic                           s_axil_awready;

    // AXI-Lite Slave Interface - Write Data
    logic   [AXI_DATA_WIDTH-1:0]    s_axil_wdata;
    logic   [AXI_DATA_WIDTH/8-1:0]  s_axil_wstrb;
    logic                           s_axil_wvalid;
    logic                           s_axil_wready;

    // AXI-Lite Slave Interface - Write Response
    logic   [1:0]                   s_axil_bresp;
    logic                           s_axil_bvalid;
    logic                           s_axil_bready;

    // AXI-Lite Slave Interface - Read Address
    logic   [AXI_ADDR_WIDTH-1:0]    s_axil_araddr;
    logic                           s_axil_arvalid;
    logic                           s_axil_arready;

    // AXI-Lite Slave Interface - Read Data
    logic   [AXI_DATA_WIDTH-1:0]    s_axil_rdata;
    logic   [1:0]                   s_axil_rresp;
    logic                           s_axil_rvalid;
    logic                           s_axil_rready;

    // Test variables
    int test_count = 0;
    int pass_count = 0;
    int fail_count = 0;

    ////////////////////////////////////////////////////////////////////////////////////
    // Clock Generation
    ////////////////////////////////////////////////////////////////////////////////////

    initial begin
        aclk = 0;
        forever #(CLOCK_PERIOD/2) aclk = ~aclk;
    end

    ////////////////////////////////////////////////////////////////////////////////////
    // Reset Generation
    ////////////////////////////////////////////////////////////////////////////////////

    initial begin
        aresetn = 0;
        #(CLOCK_PERIOD * 10);
        aresetn = 1;
    end

    ////////////////////////////////////////////////////////////////////////////////////
    // DUT Instance
    ////////////////////////////////////////////////////////////////////////////////////

    axil_master_wrapper_sv #(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
    ) dut (
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
        
        .m_axil_awaddr(s_axil_awaddr),
        .m_axil_awvalid(s_axil_awvalid),
        .m_axil_awready(s_axil_awready),
        
        .m_axil_wdata(s_axil_wdata),
        .m_axil_wstrb(s_axil_wstrb),
        .m_axil_wvalid(s_axil_wvalid),
        .m_axil_wready(s_axil_wready),
        
        .m_axil_bresp(s_axil_bresp),
        .m_axil_bvalid(s_axil_bvalid),
        .m_axil_bready(s_axil_bready),
        
        .m_axil_araddr(s_axil_araddr),
        .m_axil_arvalid(s_axil_arvalid),
        .m_axil_arready(s_axil_arready),
        
        .m_axil_rdata(s_axil_rdata),
        .m_axil_rresp(s_axil_rresp),
        .m_axil_rvalid(s_axil_rvalid),
        .m_axil_rready(s_axil_rready)
    );

    ////////////////////////////////////////////////////////////////////////////////////
    // AXI-Lite Slave Model
    ////////////////////////////////////////////////////////////////////////////////////

    // Simple AXI-Lite Slave that responds to all transactions
    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            s_axil_awready <= 1'b0;
            s_axil_wready <= 1'b0;
            s_axil_bvalid <= 1'b0;
            s_axil_bresp <= AXI_OKAY;
            s_axil_arready <= 1'b0;
            s_axil_rvalid <= 1'b0;
            s_axil_rdata <= '0;
            s_axil_rresp <= AXI_OKAY;
        end else begin
            // Write Address Channel
            if (s_axil_awvalid && !s_axil_awready) begin
                s_axil_awready <= 1'b1;
            end else if (s_axil_awready) begin
                s_axil_awready <= 1'b0;
            end

            // Write Data Channel
            if (s_axil_wvalid && !s_axil_wready) begin
                s_axil_wready <= 1'b1;
            end else if (s_axil_wready) begin
                s_axil_wready <= 1'b0;
            end

            // Write Response Channel
            if (s_axil_awready && s_axil_wready && !s_axil_bvalid) begin
                s_axil_bvalid <= 1'b1;
                s_axil_bresp <= AXI_OKAY;
            end else if (s_axil_bvalid && s_axil_bready) begin
                s_axil_bvalid <= 1'b0;
            end

            // Read Address Channel
            if (s_axil_arvalid && !s_axil_arready) begin
                s_axil_arready <= 1'b1;
            end else if (s_axil_arready) begin
                s_axil_arready <= 1'b0;
            end

            // Read Data Channel - Return some test data
            if (s_axil_arready && !s_axil_rvalid) begin
                s_axil_rvalid <= 1'b1;
                s_axil_rdata <= s_axil_araddr + 32'h1000; // Simple test data
                s_axil_rresp <= AXI_OKAY;
            end else if (s_axil_rvalid && s_axil_rready) begin
                s_axil_rvalid <= 1'b0;
            end
        end
    end

    ////////////////////////////////////////////////////////////////////////////////////
    // Test Tasks
    ////////////////////////////////////////////////////////////////////////////////////

    task write_test(input logic [AXI_ADDR_WIDTH-1:0] addr, input logic [AXI_DATA_WIDTH-1:0] data);
        automatic string test_name = $sformatf("WRITE_TEST_%0d", test_count);
        automatic int timeout = 0;
        
        test_count++;
        $display("[%0t] Starting %s: addr=0x%08h, data=0x%08h", $time, test_name, addr, data);
        
        // Wait for ready
        wait(wr_ready);
        
        // Drive write transaction
        wr_addr <= addr;
        wr_data <= data;
        wr_valid <= 1'b1;
        
        @(posedge aclk);
        wr_valid <= 1'b0;
        
        // Wait for completion
        while (!wr_done && timeout < 100) begin
            @(posedge aclk);
            timeout++;
        end
        
        if (wr_done && wr_error == AXI_OKAY) begin
            $display("[%0t] %s PASSED", $time, test_name);
            pass_count++;
        end else begin
            $display("[%0t] %s FAILED: timeout=%0d, error=0x%02h", $time, test_name, timeout, wr_error);
            fail_count++;
        end
        
        @(posedge aclk);
    endtask

    task read_test(input logic [AXI_ADDR_WIDTH-1:0] addr, input logic [AXI_DATA_WIDTH-1:0] expected_data);
        automatic string test_name = $sformatf("READ_TEST_%0d", test_count);
        automatic int timeout = 0;
        
        test_count++;
        $display("[%0t] Starting %s: addr=0x%08h, expected=0x%08h", $time, test_name, addr, expected_data);
        
        // Wait for ready
        wait(rd_ready);
        
        // Drive read transaction
        rd_addr <= addr;
        rd_valid <= 1'b1;
        
        @(posedge aclk);
        rd_valid <= 1'b0;
        
        // Wait for completion
        while (!rd_done && timeout < 100) begin
            @(posedge aclk);
            timeout++;
        end
        
        if (rd_done && rd_error == AXI_OKAY && rd_data == expected_data) begin
            $display("[%0t] %s PASSED: received=0x%08h", $time, test_name, rd_data);
            pass_count++;
        end else begin
            $display("[%0t] %s FAILED: timeout=%0d, error=0x%02h, received=0x%08h, expected=0x%08h", 
                     $time, test_name, timeout, rd_error, rd_data, expected_data);
            fail_count++;
        end
        
        @(posedge aclk);
    endtask

    ////////////////////////////////////////////////////////////////////////////////////
    // Main Test Sequence
    ////////////////////////////////////////////////////////////////////////////////////

    initial begin
        $display("==========================================");
        $display("AXI-Lite Master Testbench Starting");
        $display("==========================================");
        
        // Initialize signals
        wr_valid <= 1'b0;
        wr_addr <= '0;
        wr_data <= '0;
        rd_valid <= 1'b0;
        rd_addr <= '0;
        
        // Wait for reset release
        wait(aresetn);
        #(CLOCK_PERIOD * 5);
        
        $display("[%0t] Starting Write Tests", $time);
        
        // Write Tests
        write_test(TEST_ADDR_1, TEST_DATA_1);
        write_test(TEST_ADDR_2, TEST_DATA_2);
        write_test(TEST_ADDR_3, TEST_DATA_3);
        write_test(TEST_ADDR_4, TEST_DATA_4);
        write_test(TEST_ADDR_5, TEST_DATA_5);
        
        #(CLOCK_PERIOD * 10);
        
        $display("[%0t] Starting Read Tests", $time);
        
        // Read Tests (expecting addr + 0x1000 based on slave model)
        read_test(TEST_ADDR_1, TEST_ADDR_1 + 32'h1000);
        read_test(TEST_ADDR_2, TEST_ADDR_2 + 32'h1000);
        read_test(TEST_ADDR_3, TEST_ADDR_3 + 32'h1000);
        read_test(TEST_ADDR_4, TEST_ADDR_4 + 32'h1000);
        read_test(TEST_ADDR_5, TEST_ADDR_5 + 32'h1000);
        
        #(CLOCK_PERIOD * 10);
        
        // Test Results
        $display("==========================================");
        $display("Test Results:");
        $display("Total Tests: %0d", test_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        $display("==========================================");
        
        if (fail_count == 0) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("SOME TESTS FAILED!");
        end
        
        $finish;
    end

    ////////////////////////////////////////////////////////////////////////////////////
    // Timeout Protection
    ////////////////////////////////////////////////////////////////////////////////////

    initial begin
        #(CLOCK_PERIOD * 10000); // 10us timeout
        $display("[%0t] ERROR: Testbench timeout!", $time);
        $finish;
    end

endmodule
