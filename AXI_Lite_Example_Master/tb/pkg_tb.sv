package pkg_tb;

    // Testbench parameters
    parameter   AXI_DATA_WIDTH      = 32;
    parameter   AXI_ADDR_WIDTH      = 32;

    parameter   CLOCK               = 100_000_000;
    parameter   CLK_PERIOD_NS       = 1_000_000_000 / CLOCK;

    parameter   AXI_TRAN_MIN_DELAY  = 0;
    parameter   AXI_TRAN_MAX_DELAY  = 5;

    class AXI_Lite_Master_Write;
        virtual axil_if m_axil_if;
        
        function new(virtual axil_if m_axil_if);
            this.m_axil_if = m_axil_if;
        endfunction

        task run();
            forever
            begin
                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge m_axil_if.aclk);
                
                @(posedge m_axil_if.aclk);
                m_axil_if.awaddr = $random;
                m_axil_if.awvalid = 1;
                
                m_axil_if.wdata = $random;
                m_axil_if.wstrb = 4'b1111;
                m_axil_if.wvalid = 1;

                wait(m_axil_if.awready && m_axil_if.wready);

                @(posedge m_axil_if.aclk);
                m_axil_if.awaddr = '0;
                m_axil_if.awvalid = 0;

                m_axil_if.wdata = '0;
                m_axil_if.wstrb = '0;
                m_axil_if.wvalid = 0;
                m_axil_if.bready = 1;

                wait(m_axil_if.bvalid);

                @(posedge m_axil_if.aclk);
                m_axil_if.bready = 0;
            end
        endtask
    endclass

    class AXI_Lite_Master_Read;
        virtual axil_if m_axil_if;
        
        function new(virtual axil_if m_axil_if);
            this.m_axil_if = m_axil_if;
        endfunction

        task run();
            forever
            begin
                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge m_axil_if.aclk);
                
                @(posedge m_axil_if.aclk);
                m_axil_if.araddr = $random;
                m_axil_if.arvalid = 1;

                wait(m_axil_if.arready);

                @(posedge m_axil_if.aclk);
                m_axil_if.araddr = '0;
                m_axil_if.arvalid = 0;
                m_axil_if.rready = 1;

                wait(m_axil_if.rvalid);

                @(posedge m_axil_if.aclk);
                m_axil_if.rready = 0;
            end
        endtask
    endclass

    class AXI_Lite_Slave_Write;
        virtual axil_if s_axil_if;
        
        function new(virtual axil_if s_axil_if);
            this.s_axil_if = s_axil_if;
        endfunction

        task run();
            forever
            begin
                wait(s_axil_if.awvalid && s_axil_if.wvalid);

                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge s_axil_if.aclk);
                
                @(posedge s_axil_if.aclk);
                s_axil_if.awready = 1;
                s_axil_if.wready = 1;

                @(posedge s_axil_if.aclk);
                s_axil_if.awready = 0;
                s_axil_if.wready = 0;

                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge s_axil_if.aclk);

                s_axil_if.bvalid = 1;
                s_axil_if.bresp = 2'b00; // OKAY response
                
                wait(s_axil_if.bready);
                
                @(posedge s_axil_if.aclk);
                s_axil_if.bvalid = 0;
            end
        endtask
    endclass

    class AXI_Lite_Slave_Read;
        virtual axil_if s_axil_if;
        
        function new(virtual axil_if s_axil_if);
            this.s_axil_if = s_axil_if;
        endfunction

        task run();
            forever
            begin
                wait(s_axil_if.arvalid);

                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge s_axil_if.aclk);
                
                @(posedge s_axil_if.aclk);
                s_axil_if.arready = 1;
                
                @(posedge s_axil_if.aclk);
                s_axil_if.arready = 0;

                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge s_axil_if.aclk);

                s_axil_if.rvalid = 1;
                s_axil_if.rdata = s_axil_if.araddr + 32'h1000; // Simple test data
                s_axil_if.rresp = 2'b00; // OKAY response
                
                // Wait for rready
                wait(s_axil_if.rready);
                
                @(posedge s_axil_if.aclk);
                s_axil_if.rvalid = 0;
            end
        endtask
    endclass

endpackage
