`timescale 1ns/1ps

module axil_slave_tb;

    import pkg_tb::*;

    axil_if #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH), .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)) m_axil();

    logic                           aclk;
    logic                           aresetn;

    logic   [AXI_DATA_WIDTH-1:0]    gpio_out;

    axil_slave #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH), .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)) dut 
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .gpio_out(gpio_out),
        .s_axil(m_axil)
    );

    // AXI-Lite Master Classes
    AXI_Lite_Master_Write master_write_inst = new(m_axil);
    AXI_Lite_Master_Read  master_read_inst  = new(m_axil);

    // Statistics collector (aggregate per-agent stats)
    AXI_Lite_Master_Write write_agents[1];
    AXI_Lite_Master_Read  read_agents[1];
    StatisticsCollector    stats;

    // Bind agents to stats collector
    initial begin
        write_agents[0] = master_write_inst;
        read_agents[0]  = master_read_inst;
        stats = new(write_agents, read_agents);
    end

    assign m_axil.aclk = aclk;
    assign m_axil.aresetn = aresetn;

    // Clock
    initial begin
        aclk = 0;
        forever #(CLK_PERIOD_NS/2) aclk = ~aclk;
    end

    // Reset
    initial begin
        aresetn = 0;
        #(10*CLK_PERIOD_NS/2) aresetn = 1; 
    end

    // Init
    initial begin
        m_axil.awaddr  = '0;
        m_axil.awvalid = 0;

        m_axil.wvalid  = 0;
        m_axil.wdata   = '0;
        m_axil.wstrb   = '0;

        m_axil.araddr  = '0;
        m_axil.arvalid = 0;

        m_axil.rready  = 0;
    end

    // Slave processes
    initial begin
        fork
            master_write_inst.run();
            master_read_inst.run();
        join
    end

    // Statistics report
    initial begin
        #(1000*CLK_PERIOD_NS); // Wait 1000 cycles
        $display("==========================================");
        $display("AXI-Lite Slave Statistics");
        $display("==========================================");
        stats.print_final_stats();
        $finish;
    end

endmodule