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
        int master_id; // Добавляем идентификатор мастера
        int write_transaction_count = 0; // Счётчик транзакций записи:cite[1]

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
                
                // Увеличиваем счётчик после успешной транзакции:cite[1]
                write_transaction_count++;
                $display("Time: %0t ns - Master[%0d] Write: completed %0d transactions", 
                        $time, master_id, write_transaction_count);
            end
        endtask
        
        // Функция для получения статистики
        function void get_stats();
            $display("Master[%0d] Write Statistics: %0d transactions", 
                    master_id, write_transaction_count);
        endfunction
    endclass

    class AXI_Lite_Master_Read;
        virtual axil_if s_axil_if;
        int master_id; // Добавляем идентификатор мастера
        int read_transaction_count = 0; // Счётчик транзакций чтения:cite[1]

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
                
                // Увеличиваем счётчик после успешной транзакции:cite[1]
                read_transaction_count++;
                $display("Time: %0t ns - Master[%0d] Read: completed %0d transactions", 
                        $time, master_id, read_transaction_count);
            end
        endtask
        
        // Функция для получения статистики
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
            
            // Статистика по каждому мастеру:cite[1]
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
        
        // Функция для периодического отчёта
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

    AXI_Lite_Master_Write master_write_agents[NUMBER_MASTER];
    AXI_Lite_Master_Read master_read_agents[NUMBER_MASTER];
    AXI_Lite_Slave_Write slave_write_agents[NUMBER_SLAVE];
    AXI_Lite_Slave_Read slave_read_agents[NUMBER_SLAVE];

    // Генерация тактового сигнала
    initial
    begin
        aclk = 0;
        forever #5 aclk = ~aclk;
    end

    // Сброс
    initial 
    begin
        aresetn = 0;
        #100 aresetn = 1; 
    end

    // Инициализация и запуск агентов
    initial
    begin
        // Ждем снятия сброса
        wait(aresetn == 1);
        #10;
        
        $display("Starting AXI Lite testbench with %0d masters and %0d slaves", 
                 NUMBER_MASTER, NUMBER_SLAVE);
        
        $display("All agents started successfully");
    end

    // Объявляем коллектор статистики
    StatisticsCollector stats_collector;

    genvar i;
    generate
        for (i=0; i<NUMBER_MASTER; i++) begin : create_master_agents
            initial begin
                master_write_agents[i] = new(s_axil[i], i); // Передаём ID
                master_read_agents[i] = new(s_axil[i], i);  // Передаём ID
                fork
                    master_write_agents[i].run();
                    master_read_agents[i].run();
                join_none
            end
        end
        for (i=0; i<NUMBER_SLAVE; i++) begin : create_slave_agents
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

    // Инициализация коллектора статистики
    initial begin
        #105; // Ждём запуска агентов
        stats_collector = new(master_write_agents, master_read_agents);
    end

    // Мониторинг активности
    initial 
    begin
        #1000;
        $display("Simulation running...");
        
        // Периодический отчет о состоянии
        forever begin
            #1000;
            $display("Time: %0t ns - Simulation in progress", $time);
        end
    end

    // Завершение симуляции
    initial 
    begin
        #100000;
        stats_collector.print_final_stats();
        $display("Simulation completed");
        $finish;
    end

endmodule
