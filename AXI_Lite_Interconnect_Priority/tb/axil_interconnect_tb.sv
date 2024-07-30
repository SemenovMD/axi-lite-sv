`timescale 1ns / 1ps

module axil_interconnect_tb;

    import pkg_tb ::*;

    logic   aclk;
    logic   aresetn;

    axil_if m_axil  [NUMBER_SLAVE]    ();
    axil_if s_axil  [NUMBER_MASTER]   ();

    axil_interconnect_wrapper_sv axil_interconnect_wrapper_sv_inst 
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .m_axil(m_axil),
        .s_axil(s_axil)
    );

    class AXI_Lite_Master_Write;
        virtual axil_if s_axil_if;
        function new(virtual axil_if s_axil_if);
            this.s_axil_if = s_axil_if;
        endfunction

        task run();
            forever
            begin
                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge aclk);
                
                @(posedge aclk);
                s_axil_if.awaddr = $random;
                s_axil_if.awvalid = 1;
                
                s_axil_if.wdata = $random;
                s_axil_if.wstrb = 4'b1111;
                s_axil_if.wvalid = 1;

                wait(s_axil_if.awready && s_axil_if.wready);

                @(posedge aclk);
                s_axil_if.awaddr = '0;
                s_axil_if.awvalid = 0;

                s_axil_if.wdata = '0;
                s_axil_if.wstrb = '0;
                s_axil_if.wvalid = 0;
                s_axil_if.bready = 1;

                wait(s_axil_if.bvalid);

                @(posedge aclk);
                s_axil_if.bready = 0;
            end
        endtask
    endclass

    class AXI_Lite_Slave_Write;
        virtual axil_if m_axil_if;
        function new(virtual axil_if m_axil_if);
            this.m_axil_if = m_axil_if;
        endfunction

        task run();
            forever
            begin
                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge aclk);
                
                @(posedge aclk);
                wait(m_axil_if.awvalid && m_axil_if.wvalid);

                @(posedge aclk);
                m_axil_if.awready = 1;
                m_axil_if.wready = 1;

                @(posedge aclk);
                m_axil_if.awready = 0;
                m_axil_if.wready = 0;
                m_axil_if.bvalid = 1;
                m_axil_if.bresp = 2'b00;
 
                wait(m_axil_if.bready); 

                @(posedge aclk);
                m_axil_if.bvalid = 0;
                m_axil_if.bresp = 2'b00;
            end
        endtask
    endclass

    class AXI_Lite_Master_Read;
        virtual axil_if s_axil_if;
        function new(virtual axil_if s_axil_if);
            this.s_axil_if = s_axil_if;
        endfunction

        task run();
            forever
            begin
                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge aclk);
                
                @(posedge aclk);
                s_axil_if.araddr = $random;
                s_axil_if.arvalid = 1;

                wait(s_axil_if.arready);

                @(posedge aclk);
                s_axil_if.araddr = '0;
                s_axil_if.arvalid = 0;
                s_axil_if.rready = 1;

                wait(s_axil_if.rvalid);

                @(posedge aclk);
                s_axil_if.rready = 0;
            end
        endtask
    endclass

    class AXI_Lite_Slave_Read;
        virtual axil_if m_axil_if;
        function new(virtual axil_if m_axil_if);
            this.m_axil_if = m_axil_if;
        endfunction

        task run();
            forever
            begin
                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge aclk);
                
                @(posedge aclk);
                wait(m_axil_if.arvalid);

                @(posedge aclk);
                m_axil_if.arready = 1;

                @(posedge aclk);
                m_axil_if.arready = 0;
                m_axil_if.rdata = $random;
                m_axil_if.rvalid = 1;
                m_axil_if.rresp = 2'b00;
 
                wait(m_axil_if.rready);

                @(posedge aclk);
                m_axil_if.rdata = '0;
                m_axil_if.rvalid = 0;
                m_axil_if.rresp = 2'b00;
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

    //initial begin
    //    // Initialize Master Write Interfaces
    //    for (int i = 0; i < NUMBER_SLAVE; i++) 
    //    begin
    //        m_axil[i].awaddr = '0;
    //        m_axil[i].awvalid = 0;
    //        m_axil[i].wdata = '0;
    //        m_axil[i].wstrb = '0;
    //        m_axil[i].wvalid = 0;
    //        m_axil[i].bready = 0;
    //    end
//
    //    // Initialize Slave Write Interfaces
    //    for (int i = 0; i < NUMBER_MASTER; i++) 
    //    begin
    //        s_axil[i].awready = '0;
    //        s_axil[i].wready = 0;
    //        s_axil[i].bresp = '0;
    //        s_axil[i].bvalid = 0;
    //    end
//
    //    // Initialize Master Read Interfaces
    //    for (int i = 0; i < NUMBER_SLAVE; i++) 
    //    begin
    //        m_axil[i].araddr = '0;
    //        m_axil[i].arvalid = 0;
    //        m_axil[i].rready = 0;
    //    end
//
    //    // Initialize Slave Read Interfaces
    //    for (int i = 0; i < NUMBER_MASTER; i++) 
    //    begin
    //        s_axil[i].arready = 0;
    //        s_axil[i].rdata = '0;
    //        s_axil[i].rvalid = '0;
    //        s_axil[i].rresp = '0;
    //    end
    //end

    AXI_Lite_Master_Write   master_wr  [NUMBER_MASTER];
    AXI_Lite_Slave_Write    slave_wr   [NUMBER_SLAVE];

    AXI_Lite_Master_Read    master_rd  [NUMBER_MASTER];
    AXI_Lite_Slave_Read     slave_rd   [NUMBER_SLAVE];

    initial 
    begin
        for (int i = 0; i < NUMBER_MASTER; i++) 
        begin
            master_wr[i] = new();
            master_rd[i] = new();           
        end

        for (int j = 0; j < NUMBER_SLAVE; j++) 
        begin
            slave_wr[j] = new();
            slave_rd[j] = new();
        end

        #100;

        fork
            for (int i = 0; i < NUMBER_MASTER; i++)
            begin
                master_wr[i].run();
                master_rd[i].run();
            end

            for (int j = 0; j < NUMBER_SLAVE; j++)
            begin
                slave_wr[j].run();
                slave_rd[j].run();
            end
        join

        $finish;
    end

endmodule
