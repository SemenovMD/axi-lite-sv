package pkg_tb;

    // Testbench parameters
    parameter   AXI_DATA_WIDTH      = 32;
    parameter   AXI_ADDR_WIDTH      = 32;

    parameter   CLOCK               = 100_000_000;
    parameter   CLK_PERIOD_NS       = 1_000_000_000 / CLOCK;

    parameter   AXI_TRAN_MIN_DELAY  = 0;
    parameter   AXI_TRAN_MAX_DELAY  = 5;

    class AXI_Lite_Master_Write;
        virtual axil_if s_axil_if;
        int master_id;
        int write_transaction_count = 0;

        function new(virtual axil_if s_axil_if, int id = 0);
            this.s_axil_if = s_axil_if;
            this.master_id = id;
            
            s_axil_if.awvalid = 0;
            s_axil_if.wvalid = 0;
            s_axil_if.bready = 0;
        endfunction

        task run();
            s_axil_if.awvalid = 0;
            s_axil_if.wvalid = 0;
            s_axil_if.bready = 0;

            forever
            begin
                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge s_axil_if.aclk);
                
                @(posedge s_axil_if.aclk);
                s_axil_if.awaddr = $random;
                s_axil_if.awvalid = 1;
                
                s_axil_if.wdata = $random;
                s_axil_if.wstrb = 4'b1111;
                s_axil_if.wvalid = 1;

                wait(s_axil_if.awready && s_axil_if.wready);

                @(posedge s_axil_if.aclk);
                s_axil_if.awaddr = '0;
                s_axil_if.awvalid = 0;

                s_axil_if.wdata = '0;
                s_axil_if.wstrb = '0;
                s_axil_if.wvalid = 0;
                s_axil_if.bready = 1;

                wait(s_axil_if.bvalid);

                @(posedge s_axil_if.aclk);
                s_axil_if.bready = 0;
                
                write_transaction_count++;
                $display("Time: %0t ns - Master[%0d] Write: completed %0d transactions", 
                        $time, master_id, write_transaction_count);
            end
        endtask
        
        function void get_stats();
            $display("Master[%0d] Write Statistics: %0d transactions", 
                    master_id, write_transaction_count);
        endfunction
    endclass

    class AXI_Lite_Master_Read;
        virtual axil_if s_axil_if;
        int master_id;
        int read_transaction_count = 0;

        function new(virtual axil_if s_axil_if, int id = 0);
            this.s_axil_if = s_axil_if;
            this.master_id = id;
            
            s_axil_if.arvalid = 0;
            s_axil_if.rready = 0;
        endfunction

        task run();
            s_axil_if.arvalid = 0;
            s_axil_if.rready = 0;

            forever
            begin
                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge s_axil_if.aclk);
                
                @(posedge s_axil_if.aclk);
                s_axil_if.araddr = $random;
                s_axil_if.arvalid = 1;

                wait(s_axil_if.arready);

                @(posedge s_axil_if.aclk);
                s_axil_if.araddr = '0;
                s_axil_if.arvalid = 0;
                s_axil_if.rready = 1;

                wait(s_axil_if.rvalid);

                @(posedge s_axil_if.aclk);
                s_axil_if.rready = 0;
                
                read_transaction_count++;
                $display("Time: %0t ns - Master[%0d] Read: completed %0d transactions", 
                        $time, master_id, read_transaction_count);
            end
        endtask
        
        function void get_stats();
            $display("Master[%0d] Read Statistics:  %0d transactions", 
                    master_id, read_transaction_count);
        endfunction
    endclass

    class AXI_Lite_Slave_Write;
        virtual axil_if m_axil_if;
        function new(virtual axil_if m_axil_if);
            this.m_axil_if = m_axil_if;

            m_axil_if.awready = 0;
            m_axil_if.wready = 0;
            m_axil_if.bvalid = 0;
            m_axil_if.bresp = 0;
        endfunction

        task run();
            m_axil_if.awready = 0;
            m_axil_if.wready = 0;
            m_axil_if.bvalid = 0;
            m_axil_if.bresp = 0;

            forever
            begin
                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge m_axil_if.aclk);
                
                @(posedge m_axil_if.aclk);
                wait(m_axil_if.awvalid && m_axil_if.wvalid);

                @(posedge m_axil_if.aclk);
                m_axil_if.awready = 1;
                m_axil_if.wready = 1;

                @(posedge m_axil_if.aclk);
                m_axil_if.awready = 0;
                m_axil_if.wready = 0;
                m_axil_if.bvalid = 1;
                m_axil_if.bresp = 2'b00;

                wait(m_axil_if.bready); 

                @(posedge m_axil_if.aclk);
                m_axil_if.bvalid = 0;
                m_axil_if.bresp = 2'b00;
            end
        endtask
    endclass

    class AXI_Lite_Slave_Read;
        virtual axil_if m_axil_if;
        function new(virtual axil_if m_axil_if);
            this.m_axil_if = m_axil_if;

            m_axil_if.arready = 0;
            m_axil_if.rvalid = 0;
            m_axil_if.rdata = 0;
            m_axil_if.rresp = 0;
        endfunction

        task run();
            m_axil_if.arready = 0;
            m_axil_if.rvalid = 0;
            m_axil_if.rdata = 0;
            m_axil_if.rresp = 0;

            forever
            begin
                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge m_axil_if.aclk);
                
                @(posedge m_axil_if.aclk);
                wait(m_axil_if.arvalid);

                @(posedge m_axil_if.aclk);
                m_axil_if.arready = 1;

                @(posedge m_axil_if.aclk);
                m_axil_if.arready = 0;
                m_axil_if.rdata = $random;
                m_axil_if.rvalid = 1;
                m_axil_if.rresp = 2'b00;
 
                wait(m_axil_if.rready);

                @(posedge m_axil_if.aclk);
                m_axil_if.rdata = '0;
                m_axil_if.rvalid = 0;
                m_axil_if.rresp = 2'b00;
            end
        endtask
    endclass

    class StatisticsCollector;
        AXI_Lite_Master_Write master_write_agents[];
        AXI_Lite_Master_Read master_read_agents[];
        int total_write_transactions = 0;
        int total_read_transactions = 0;
        int total_transactions = 0;
        
        function new(AXI_Lite_Master_Write write_agents[], 
                    AXI_Lite_Master_Read read_agents[]);
            this.master_write_agents = write_agents;
            this.master_read_agents = read_agents;
        endfunction
        
        function void print_final_stats();
            $display("\n=== FINAL TRANSACTION STATISTICS ===");
            $display("Time: %0t ns", $time);
            
            foreach(master_write_agents[i]) begin
                master_write_agents[i].get_stats();
                master_read_agents[i].get_stats();
                
                total_write_transactions += master_write_agents[i].write_transaction_count;
                total_read_transactions += master_read_agents[i].read_transaction_count;
            end
            
            total_transactions = total_write_transactions + total_read_transactions;
            
            $display("\n=== SUMMARY ===");
            $display("Total Write Transactions: %0d", total_write_transactions);
            $display("Total Read Transactions:  %0d", total_read_transactions);
            $display("Total Transactions: %0d", total_transactions);
            $display("====================\n");
        endfunction
        
        function void print_periodic_stats();
            $display("\n--- Periodic Statistics at %0t ns ---", $time);
            foreach(master_write_agents[i]) begin
                $display("Master[%0d]: %0d writes, %0d reads", i,
                        master_write_agents[i].write_transaction_count,
                        master_read_agents[i].read_transaction_count);
            end
            $display("-----------------------------------\n");
        endfunction
    endclass

endpackage
