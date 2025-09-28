`timescale 1ns/1ps

module axil_master_tb;

    import pkg_tb::*;

    axil_if #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH), .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)) s_axil();

    logic                           aclk;
    logic                           aresetn;

    logic                           wr_valid;
    logic                           wr_ready;
    logic   [AXI_ADDR_WIDTH-1:0]    wr_addr;
    logic   [AXI_DATA_WIDTH-1:0]    wr_data;
    logic                           wr_done;
    logic   [1:0]                   wr_error;

    logic                           rd_valid;
    logic                           rd_ready;
    logic   [AXI_ADDR_WIDTH-1:0]    rd_addr;
    logic   [AXI_DATA_WIDTH-1:0]    rd_data;
    logic                           rd_done;
    logic   [1:0]                   rd_error;

    int                             wr_count = 0;
    int                             rd_count = 0;
    int                             wr_errors = 0;
    int                             rd_errors = 0;

    axil_master #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH), .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)) axil_master_inst 
    (
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

        .m_axil(s_axil)
    );

    // AXI-Lite Slave Classes
    AXI_Lite_Slave_Write slave_write_inst = new(s_axil);
    AXI_Lite_Slave_Read  slave_read_inst  = new(s_axil);

    assign s_axil.aclk = aclk;
    assign s_axil.aresetn = aresetn;

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
        wr_valid = 0;
        wr_addr  = '0;
        wr_data  = '0;

        rd_valid = 0;
        rd_addr  = '0;

        s_axil.awready = 0;
        s_axil.wready  = 0;
        s_axil.bvalid  = 0;
        s_axil.bresp   = '0;

        s_axil.arready = 0;
        s_axil.rdata   = '0;
        s_axil.rvalid  = 0;
        s_axil.rresp   = '0;
    end

    // Count write transactions and errors
    always @(posedge aclk) begin
        if (aresetn && wr_done) begin
            wr_count++;
            if (wr_error != 2'b00) begin
                wr_errors++;
            end
        end
    end

    // Count read transactions and errors
    always @(posedge aclk) begin
        if (aresetn && rd_done) begin
            rd_count++;
            if (rd_error != 2'b00) begin
                rd_errors++;
            end
        end
    end

    // Random WRITE transactions
    initial begin
        forever begin
            repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge aclk);

            wr_valid = 1;
            wr_addr  = $random();
            wr_data  = $random();

            wait(wr_ready);

            @(posedge aclk);
            wr_valid = 0;
            wr_addr  = '0;
            wr_data  = '0;

            wait(wr_done);
        end
    end

    // Random READ transactions
    initial begin
        forever begin
            repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge aclk);

            rd_valid = 1;
            rd_addr  = $random();

            wait(rd_ready);

            @(posedge aclk);
            rd_valid = 0;
            rd_addr  = '0;

            wait(rd_done);
        end
    end

    // Slave processes
    initial begin
        fork
            slave_write_inst.run();
            slave_read_inst.run();
        join
    end

    // Statistics report
    initial begin
        #(1000*CLK_PERIOD_NS); // Wait 1000 cycles
        
        $display("==========================================");
        $display("AXI-Lite Master Statistics");
        $display("==========================================");
        $display("WRITE Transactions: %0d", wr_count);
        $display("WRITE Errors: %0d", wr_errors);
        $display("READ Transactions: %0d", rd_count);
        $display("READ Errors: %0d", rd_errors);
        $display("==========================================");
        
        $finish;
    end

endmodule