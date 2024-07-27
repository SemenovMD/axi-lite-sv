`timescale 1ns / 1ps

module axil_interconnect_tb;

    import pkg_tb::*;
    
    // Сигналы
    logic                               aclk;
    logic                               aresetn;

    // Сигналы для каналов мастеров записи
    logic [AXI_ADDR_WIDTH-1:0]          m_axil_awaddr           [NUMBER_MASTER];
    logic [NUMBER_MASTER-1:0]           m_axil_awvalid;
    logic [NUMBER_MASTER-1:0]           m_axil_awready;

    logic [AXI_DATA_WIDTH-1:0]          m_axil_wdata            [NUMBER_MASTER];
    logic [AXI_DATA_WIDTH/8-1:0]        m_axil_wstrb            [NUMBER_MASTER];
    logic [NUMBER_MASTER-1:0]           m_axil_wvalid;
    logic [NUMBER_MASTER-1:0]           m_axil_wready;

    logic [1:0]                         m_axil_bresp            [NUMBER_MASTER];
    logic [NUMBER_MASTER-1:0]           m_axil_bvalid;
    logic [NUMBER_MASTER-1:0]           m_axil_bready;

    // Сигналы для каналов слейвов записи
    logic [AXI_ADDR_WIDTH-1:0]          s_axil_awaddr           [NUMBER_SLAVE];
    logic [NUMBER_SLAVE-1:0]            s_axil_awvalid;
    logic [NUMBER_SLAVE-1:0]            s_axil_awready;

    logic [AXI_DATA_WIDTH-1:0]          s_axil_wdata            [NUMBER_SLAVE];
    logic [AXI_DATA_WIDTH/8-1:0]        s_axil_wstrb            [NUMBER_SLAVE];
    logic [NUMBER_SLAVE-1:0]            s_axil_wvalid;
    logic [NUMBER_SLAVE-1:0]            s_axil_wready;

    logic [1:0]                         s_axil_bresp            [NUMBER_SLAVE];
    logic [NUMBER_SLAVE-1:0]            s_axil_bvalid;
    logic [NUMBER_SLAVE-1:0]            s_axil_bready;

    // Сигналы для каналов мастеров чтения
    logic   [AXI_ADDR_WIDTH-1:0]        m_axil_araddr           [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]         m_axil_arvalid;
    logic   [NUMBER_MASTER-1:0]         m_axil_arready;

    logic   [AXI_DATA_WIDTH-1:0]        m_axil_rdata            [NUMBER_MASTER];
    logic   [1:0]                       m_axil_rresp            [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]         m_axil_rvalid;
    logic   [NUMBER_MASTER-1:0]         m_axil_rready;

    // Сигналы для каналов слейвов чтения
    logic   [AXI_ADDR_WIDTH-1:0]        s_axil_araddr           [NUMBER_SLAVE];
    logic   [NUMBER_SLAVE-1:0]          s_axil_arvalid;
    logic   [NUMBER_SLAVE-1:0]          s_axil_arready;

    logic   [AXI_DATA_WIDTH-1:0]        s_axil_rdata            [NUMBER_SLAVE];
    logic   [1:0]                       s_axil_rresp            [NUMBER_SLAVE];
    logic   [NUMBER_SLAVE-1:0]          s_axil_rvalid;
    logic   [NUMBER_SLAVE-1:0]          s_axil_rready;

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
        .s_axil_bready(s_axil_bready),
        .m_axil_araddr(m_axil_araddr),
        .m_axil_arvalid(m_axil_arvalid),
        .m_axil_arready(m_axil_arready),
        .m_axil_rdata(m_axil_rdata),
        .m_axil_rresp(m_axil_rresp),
        .m_axil_rvalid(m_axil_rvalid),
        .m_axil_rready(m_axil_rready),
        .s_axil_araddr(s_axil_araddr),
        .s_axil_arvalid(s_axil_arvalid),
        .s_axil_arready(s_axil_arready),
        .s_axil_rdata(s_axil_rdata),
        .s_axil_rresp(s_axil_rresp),
        .s_axil_rvalid(s_axil_rvalid),
        .s_axil_rready(s_axil_rready)
    );

    class AXI_Lite_Master_Write;
        int master_id;
        function new(int id);
            this.master_id = id;
        endfunction

        task run();
            forever
            begin
                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge aclk);
                
                @(posedge aclk);
                m_axil_awaddr[master_id] = $random;
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

    class AXI_Lite_Slave_Write;
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

    class AXI_Lite_Master_Read;
        int master_id;
        function new(int id);
            this.master_id = id;
        endfunction

        task run();
            forever
            begin
                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge aclk);
                
                @(posedge aclk);
                m_axil_araddr[master_id] = $random;
                m_axil_arvalid[master_id] = 1;

                wait(m_axil_arready[master_id]);

                @(posedge aclk);
                m_axil_araddr[master_id] = '0;
                m_axil_arvalid[master_id] = 0;

                wait(m_axil_rvalid[master_id]);

                @(posedge aclk);
                m_axil_rready[master_id] = 1;

                @(posedge aclk);
                m_axil_rready[master_id] = 0;
            end
        endtask
    endclass

    class AXI_Lite_Slave_Read;
        int slave_id;
        function new(int id);
            this.slave_id = id;
        endfunction

        task run();
            forever
            begin
                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge aclk);
                
                @(posedge aclk);
                wait(s_axil_arvalid[slave_id]);

                @(posedge aclk);
                s_axil_arready[slave_id] = 1;

                @(posedge aclk);
                s_axil_arready[slave_id] = 0;
                s_axil_rdata[slave_id] = $random;
                s_axil_rvalid[slave_id] = 1;
                s_axil_rresp[slave_id] = 2'b11;
 
                wait(s_axil_rready[slave_id]); 

                @(posedge aclk);
                s_axil_rdata[slave_id] = '0;
                s_axil_rvalid[slave_id] = 1;
                s_axil_rresp[slave_id] = 2'b00;
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
        // Initialize Master Write Interfaces
        for (int i = 0; i < NUMBER_MASTER; i++) 
        begin
            m_axil_awaddr[i] = '0;
            m_axil_awvalid[i] = 0;
            m_axil_wdata[i] = '0;
            m_axil_wstrb[i] = '0;
            m_axil_wvalid[i] = 0;
            m_axil_bready[i] = 0;
        end

        // Initialize Slave Write Interfaces
        for (int i = 0; i < NUMBER_SLAVE; i++) 
        begin
            s_axil_awready[i] = '0;
            s_axil_wready[i] = 0;
            s_axil_bresp[i] = '0;
            s_axil_bvalid[i] = 0;
        end

        // Initialize Master Read Interfaces
        for (int i = 0; i < NUMBER_MASTER; i++) 
        begin
            m_axil_araddr[i] = '0;
            m_axil_arvalid[i] = 0;
            m_axil_rready[i] = 0;
        end

        // Initialize Slave Read Interfaces
        for (int i = 0; i < NUMBER_SLAVE; i++) 
        begin
            s_axil_arready[i] = 0;
            s_axil_rdata[i] = '0;
            s_axil_rvalid[i] = '0;
            s_axil_rresp[i] = '0;
        end
    end

    AXI_Lite_Master_Write   master_wr  [NUMBER_MASTER];
    AXI_Lite_Slave_Write    slave_wr   [NUMBER_SLAVE];

    AXI_Lite_Master_Read    master_rd  [NUMBER_MASTER];
    AXI_Lite_Slave_Read     slave_rd   [NUMBER_SLAVE];

    initial 
    begin
        for (int i = 0; i < NUMBER_MASTER; i++) 
        begin
            master_wr[i] = new(i);
            master_rd[i] = new(i);           
        end

        for (int j = 0; j < NUMBER_SLAVE; j++) 
        begin
            slave_wr[j] = new(j);
            slave_rd[j] = new(j);
        end

        #100;

        fork
            master_wr[0].run();    master_wr[1].run();    master_wr[2].run();    master_wr[3].run(); 
            master_wr[4].run();    master_wr[5].run();    master_wr[6].run();    master_wr[7].run();
            master_wr[8].run();    master_wr[9].run();    master_wr[10].run();   master_wr[11].run();
            master_wr[12].run();   master_wr[13].run();   master_wr[14].run();   master_wr[15].run();
            master_wr[16].run();   master_wr[17].run();   master_wr[18].run();   master_wr[19].run();
            master_wr[20].run();   master_wr[21].run();   master_wr[22].run();   master_wr[23].run();
            master_wr[24].run();   master_wr[25].run();   master_wr[26].run();   master_wr[27].run();
            master_wr[28].run();   master_wr[29].run();   master_wr[30].run();   master_wr[31].run();

            slave_wr[0].run();     slave_wr[1].run();     slave_wr[2].run();     slave_wr[3].run();
            slave_wr[4].run();     slave_wr[5].run();     slave_wr[6].run();     slave_wr[7].run();
            slave_wr[8].run();     slave_wr[9].run();     slave_wr[10].run();    slave_wr[11].run();  
            slave_wr[12].run();    slave_wr[13].run();    slave_wr[14].run();    slave_wr[15].run();



            master_rd[0].run();    master_rd[1].run();    master_rd[2].run();    master_rd[3].run(); 
            master_rd[4].run();    master_rd[5].run();    master_rd[6].run();    master_rd[7].run();
            master_rd[8].run();    master_rd[9].run();    master_rd[10].run();   master_rd[11].run();
            master_rd[12].run();   master_rd[13].run();   master_rd[14].run();   master_rd[15].run();
            master_rd[16].run();   master_rd[17].run();   master_rd[18].run();   master_rd[19].run();
            master_rd[20].run();   master_rd[21].run();   master_rd[22].run();   master_rd[23].run();
            master_rd[24].run();   master_rd[25].run();   master_rd[26].run();   master_rd[27].run();
            master_rd[28].run();   master_rd[29].run();   master_rd[30].run();   master_rd[31].run();

            slave_rd[0].run();     slave_rd[1].run();     slave_rd[2].run();     slave_rd[3].run();
            slave_rd[4].run();     slave_rd[5].run();     slave_rd[6].run();     slave_rd[7].run();
            slave_rd[8].run();     slave_rd[9].run();     slave_rd[10].run();    slave_rd[11].run();  
            slave_rd[12].run();    slave_rd[13].run();    slave_rd[14].run();    slave_rd[15].run();
        join

        $finish;
    end

endmodule