`timescale 1ns / 1ps

module axil_interconnect_tb;

    import pkg_tb ::*;

    logic   aclk;
    logic   aresetn;

    // Interfaces
    axil_if m_axil  [NUMBER_SLAVE]    ();
    axil_if s_axil  [NUMBER_MASTER]   ();

    // DUT
    axil_interconnect_wrapper_sv axil_interconnect_wrapper_sv_inst 
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .m_axil(m_axil),
        .s_axil(s_axil)
    );

    // Clock
    initial begin
        aclk = 0;
        forever #5 aclk = ~aclk;
    end

    // Reset
    initial begin
        aresetn = 0;
        #100 aresetn = 1;
        $display("Starting AXI Lite testbench with %0d masters and %0d slaves", 
                 NUMBER_MASTER, NUMBER_SLAVE);
        
        $display("All agents started successfully");
    end
    
    // Agents
    AXI_Lite_Master_Write master_write_agents[NUMBER_MASTER];
    AXI_Lite_Master_Read  master_read_agents[NUMBER_MASTER];
    AXI_Lite_Slave_Write  slave_write_agents[NUMBER_SLAVE];
    AXI_Lite_Slave_Read   slave_read_agents[NUMBER_SLAVE];

    // Statistics
    StatisticsCollector stats_collector;

    // Generate
    generate
        // Clock connections
        for (genvar j = 0; j < NUMBER_MASTER; j++) begin : connect_master_clk
            assign s_axil[j].aclk = aclk;
            assign s_axil[j].aresetn = aresetn;
        end

        // Clock connections
        for (genvar j = 0; j < NUMBER_SLAVE; j++) begin : connect_slave_clk  
            assign m_axil[j].aclk = aclk;
            assign m_axil[j].aresetn = aresetn;
        end

        // Agent creation
        for (genvar i=0; i<NUMBER_MASTER; i++) begin : create_master_agents
            initial begin
                master_write_agents[i] = new(s_axil[i], i);
                master_read_agents[i] = new(s_axil[i], i);
                fork
                    master_write_agents[i].run();
                    master_read_agents[i].run();
                join_none
            end
        end

        // Agent creation
        for (genvar i=0; i<NUMBER_SLAVE; i++) begin : create_slave_agents
            initial begin
                slave_write_agents[i] = new(m_axil[i]);
                slave_read_agents[i] = new(m_axil[i]);
                fork
                    slave_write_agents[i].run();
                    slave_read_agents[i].run();
                join_none
            end
        end
    endgenerate

    // Initialization
    initial begin
        #105;
        wait(master_write_agents[0] != null && slave_write_agents[0] != null);
        stats_collector = new(master_write_agents, master_read_agents);
        $display("Statistics collector initialized");
    end

    // Monitoring
    initial begin
        #1000;
        $display("Simulation running...");
        
        forever begin
            #5000;
            stats_collector.print_periodic_stats();
            $display("Time: %0t ns - Simulation in progress", $time);
            
            if (stats_collector.total_transactions == 0) 
                $warning("No transactions detected yet!");
        end
    end

    // Final
    initial begin
        #50000;
        stats_collector.print_final_stats();
        $display("Simulation completed");
        $finish;
    end

endmodule