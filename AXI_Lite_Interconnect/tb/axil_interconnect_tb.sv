`timescale 1ns / 1ps

module axil_interconnect_tb;

    import pkg_tb::*;
    
    // Сигналы
    logic                           aclk;
    logic                           aresetn;

    // Сигналы для каналов мастеров
    logic [AXI_ADDR_WIDTH-1:0]      m_axil_awaddr[NUMBER_MASTER];
    logic [NUMBER_MASTER-1:0]       m_axil_awvalid;
    logic [NUMBER_MASTER-1:0]       m_axil_awready;

    logic [AXI_DATA_WIDTH-1:0]      m_axil_wdata[NUMBER_MASTER];
    logic [AXI_DATA_WIDTH/8-1:0]    m_axil_wstrb[NUMBER_MASTER];
    logic [NUMBER_MASTER-1:0]       m_axil_wvalid;
    logic [NUMBER_MASTER-1:0]       m_axil_wready;

    logic [1:0]                     m_axil_bresp[NUMBER_MASTER];
    logic [NUMBER_MASTER-1:0]       m_axil_bvalid;
    logic [NUMBER_MASTER-1:0]       m_axil_bready;

    // Сигналы для каналов слейвов
    logic [AXI_ADDR_WIDTH-1:0]      s_axil_awaddr[NUMBER_SLAVE];
    logic [NUMBER_SLAVE-1:0]        s_axil_awvalid;
    logic [NUMBER_SLAVE-1:0]        s_axil_awready;

    logic [AXI_DATA_WIDTH-1:0]      s_axil_wdata[NUMBER_SLAVE];
    logic [AXI_DATA_WIDTH/8-1:0]    s_axil_wstrb[NUMBER_SLAVE];
    logic [NUMBER_SLAVE-1:0]        s_axil_wvalid;
    logic [NUMBER_SLAVE-1:0]        s_axil_wready;

    logic [1:0]                     s_axil_bresp[NUMBER_SLAVE];
    logic [NUMBER_SLAVE-1:0]        s_axil_bvalid;
    logic [NUMBER_SLAVE-1:0]        s_axil_bready;

    axil_interconnect_wrapper #
    
    (
        .NUMBER_MASTER(NUMBER_MASTER),
        .NUMBER_SLAVE(NUMBER_SLAVE),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_ADDR_OFFSET(AXI_ADDR_OFFSET),
        .AXI_ADDR_RANGE(AXI_ADDR_RANGE)
    ) 
    
    axil_interconnect_wrapper_inst 
    
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .m_axil_awaddr(m_axil_awaddr),
        .m_axil_awvalid(m_axil_awvalid),
        .m_axil_awready(m_axil_awready),
        .m_axil_wdata(m_axil_wdata),
        .m_axil_wstrb(m_axil_wstrb),
        .m_axil_wvalid(m_axil_wvalid),
        .m_axil_wready(m_axil_wready),
        .m_axil_bresp(m_axil_bresp),
        .m_axil_bvalid(m_axil_bvalid),
        .m_axil_bready(m_axil_bready),
        .s_axil_awaddr(s_axil_awaddr),
        .s_axil_awvalid(s_axil_awvalid),
        .s_axil_awready(s_axil_awready),
        .s_axil_wdata(s_axil_wdata),
        .s_axil_wstrb(s_axil_wstrb),
        .s_axil_wvalid(s_axil_wvalid),
        .s_axil_wready(s_axil_wready),
        .s_axil_bresp(s_axil_bresp),
        .s_axil_bvalid(s_axil_bvalid),
        .s_axil_bready(s_axil_bready)
    );

    class Master;
        int master_id;
        function new(int id);
            this.master_id = id;
        endfunction

        task run();
            forever
            begin
                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge aclk);
                
                @(posedge aclk);
                m_axil_awaddr[master_id] = AXI_ADDR_OFFSET[$urandom_range(0, NUMBER_SLAVE-1)];
                m_axil_awvalid[master_id] = 1;
                
                m_axil_wdata[master_id] = $random;
                m_axil_wstrb[master_id] = 4'b1111;
                m_axil_wvalid[master_id] = 1;

                wait(m_axil_awready[master_id] && m_axil_wready[master_id]);

                @(posedge aclk);
                m_axil_awaddr[master_id] = '0;
                m_axil_awvalid[master_id] = 0;

                m_axil_wdata[master_id] = '0;
                m_axil_wstrb[master_id] = '0;
                m_axil_wvalid[master_id] = 0;
                m_axil_bready[master_id] = 1;

                wait(m_axil_bvalid[master_id]);

                @(posedge aclk);
                m_axil_bready[master_id] = 0;
            end
        endtask
    endclass

    class Slave;
        int slave_id;
        function new(int id);
            this.slave_id = id;
        endfunction

        task run();
            forever
            begin
                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge aclk);
                
                @(posedge aclk);
                wait(s_axil_awvalid[slave_id] && s_axil_wvalid[slave_id]);

                @(posedge aclk);
                s_axil_awready[slave_id] = 1;
                s_axil_wready[slave_id] = 1;

                @(posedge aclk);
                s_axil_awready[slave_id] = 0;
                s_axil_wready[slave_id] = 0;
                s_axil_bvalid[slave_id] = 1;
                s_axil_bresp[slave_id] = 2'b00;
 
                wait(s_axil_bready[slave_id]); 

                @(posedge aclk);
                s_axil_bvalid[slave_id] = 0;
                s_axil_bresp[slave_id] = 2'b00;
            end
        endtask
    endclass

    initial
    begin
        aclk = 0;
        forever #5 aclk = ~aclk;
    end

    initial 
    begin
        aresetn = 0;
        #15 aresetn = 1; 
    end

    initial begin
        // Initialize Master Interfaces
        for (int i = 0; i < NUMBER_MASTER; i++) 
        begin
            m_axil_awaddr[i] = '0;
            m_axil_awvalid[i] = '0;
            m_axil_wdata[i] = '0;
            m_axil_wstrb[i] = '0;
            m_axil_wvalid[i] = '0;
            m_axil_bready[i] = '0;
        end

        // Initialize Slave Interfaces
        for (int i = 0; i < NUMBER_SLAVE; i++) 
        begin
            s_axil_awready[i] = '0;
            s_axil_wready[i] = '0;
            s_axil_bresp[i] = '0;
            s_axil_bvalid[i] = '0;
        end
    end

    initial 
    begin
        Master master0 = new(0);
        Master master1 = new(1);
        Slave slave0 = new(0);
        Slave slave1 = new(1);
        Slave slave2 = new(2);
        Slave slave3 = new(3);

        #100;

        fork
            master0.run();
            master1.run();
            slave0.run();
            slave1.run();
            slave2.run();
            slave3.run();
        join

        $finish;
    end

endmodule