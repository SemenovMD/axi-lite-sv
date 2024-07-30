`timescale 1ns / 1ps

module axil_interconnect_tb;

    import pkg_tb ::*;
    
    logic                               aclk;
    logic                               aresetn;

    axil_if                             m_axil()    [NUMBER_SLAVE];
    axil_if                             s_axil()    [NUMBER_MASTER];


    axil_interconnect_wrapper_sv axil_interconnect_wrapper_sv_inst 
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .m_axil(m_axil),
        .s_axil(s_axil)
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
                s_axil.awaddr[master_id] = $random;
                s_axil.awvalid[master_id] = 1;
                
                s_axil.wdata[master_id] = $random;
                s_axil.wstrb[master_id] = 4'b1111;
                s_axil.wvalid[master_id] = 1;

                wait(s_axil.awready[master_id] && s_axil.wready[master_id]);

                @(posedge aclk);
                s_axil.awaddr[master_id] = '0;
                s_axil.awvalid[master_id] = 0;

                s_axil.wdata[master_id] = '0;
                s_axil.wstrb[master_id] = '0;
                s_axil.wvalid[master_id] = 0;
                s_axil.bready[master_id] = 1;

                wait(s_axil.bvalid[master_id]);

                @(posedge aclk);
                s_axil.bready[master_id] = 0;
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
                wait(m_axil.awvalid[slave_id] && m_axil.wvalid[slave_id]);

                @(posedge aclk);
                m_axil.awready[slave_id] = 1;
                m_axil.wready[slave_id] = 1;

                @(posedge aclk);
                m_axil.awready[slave_id] = 0;
                m_axil.wready[slave_id] = 0;
                m_axil.bvalid[slave_id] = 1;
                m_axil.bresp[slave_id] = 2'b00;
 
                wait(m_axil.bready[slave_id]); 

                @(posedge aclk);
                m_axil.bvalid[slave_id] = 0;
                m_axil.bresp[slave_id] = 2'b00;
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
                s_axil.araddr[master_id] = $random;
                s_axil.arvalid[master_id] = 1;

                wait(s_axil.arready[master_id]);

                @(posedge aclk);
                s_axil.araddr[master_id] = '0;
                s_axil.arvalid[master_id] = 0;
                s_axil.rready[master_id] = 1;

                wait(s_axil.rvalid[master_id]);

                @(posedge aclk);
                s_axil.rready[master_id] = 0;
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
                wait(m_axil.arvalid[slave_id]);

                @(posedge aclk);
                m_axil.arready[slave_id] = 1;

                @(posedge aclk);
                m_axil.arready[slave_id] = 0;
                m_axil.rdata[slave_id] = $random;
                m_axil.rvalid[slave_id] = 1;
                m_axil.rresp[slave_id] = 2'b00;
 
                wait(m_axil.rready[slave_id]);

                @(posedge aclk);
                m_axil.rdata[slave_id] = '0;
                m_axil.rvalid[slave_id] = 0;
                m_axil.rresp[slave_id] = 2'b00;
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
        #100 aresetn = 1; 
    end

    initial begin
        // Initialize Master Write Interfaces
        for (int i = 0; i < NUMBER_MASTER; i++) 
        begin
            s_axil.awaddr[i] = '0;
            s_axil.awvalid[i] = 0;
            s_axil.wdata[i] = '0;
            s_axil.wstrb[i] = '0;
            s_axil.wvalid[i] = 0;
            s_axil.bready[i] = 0;
        end

        // Initialize Slave Write Interfaces
        for (int i = 0; i < NUMBER_SLAVE; i++) 
        begin
            m_axil.awready[i] = '0;
            m_axil.wready[i] = 0;
            m_axil.bresp[i] = '0;
            m_axil.bvalid[i] = 0;
        end

        // Initialize Master Read Interfaces
        for (int i = 0; i < NUMBER_MASTER; i++) 
        begin
            s_axil.araddr[i] = '0;
            s_axil.arvalid[i] = 0;
            s_axil.rready[i] = 0;
        end

        // Initialize Slave Read Interfaces
        for (int i = 0; i < NUMBER_SLAVE; i++) 
        begin
            m_axil.arready[i] = 0;
            m_axil.rdata[i] = '0;
            m_axil.rvalid[i] = '0;
            m_axil.rresp[i] = '0;
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