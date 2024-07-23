`timescale 1ns / 1ps

module axil_crossbar_wr_tb;

    // Параметры
    localparam NUMBER_MASTER = 2;
    localparam NUMBER_SLAVE = 4;
    localparam AXI_DATA_WIDTH = 8;
    localparam AXI_ADDR_WIDTH = 8;
    
    // Сигналы
    logic [$clog2(NUMBER_MASTER)-1:0] grant_wr[NUMBER_SLAVE];
    logic [$clog2(NUMBER_SLAVE)-1:0] grant_wr_trans[NUMBER_MASTER];

    // Сигналы для каналов мастеров
    logic [AXI_ADDR_WIDTH-1:0] m_axil_awaddr[NUMBER_MASTER];
    logic [NUMBER_MASTER-1:0] m_axil_awvalid;
    logic [NUMBER_MASTER-1:0] m_axil_awready;

    logic [AXI_DATA_WIDTH-1:0] m_axil_wdata[NUMBER_MASTER];
    logic [AXI_DATA_WIDTH/8-1:0] m_axil_wstrb[NUMBER_MASTER];
    logic [NUMBER_MASTER-1:0] m_axil_wvalid;
    logic [NUMBER_MASTER-1:0] m_axil_wready;

    logic [1:0] m_axil_bresp[NUMBER_MASTER];
    logic [NUMBER_MASTER-1:0] m_axil_bvalid;
    logic [NUMBER_MASTER-1:0] m_axil_bready;

    // Сигналы для каналов слейвов
    logic [AXI_ADDR_WIDTH-1:0] s_axil_awaddr[NUMBER_SLAVE];
    logic [NUMBER_SLAVE-1:0] s_axil_awvalid;
    logic [NUMBER_SLAVE-1:0] s_axil_awready;

    logic [AXI_DATA_WIDTH-1:0] s_axil_wdata[NUMBER_SLAVE];
    logic [AXI_DATA_WIDTH/8-1:0] s_axil_wstrb[NUMBER_SLAVE];
    logic [NUMBER_SLAVE-1:0] s_axil_wvalid;
    logic [NUMBER_SLAVE-1:0] s_axil_wready;

    logic [1:0] s_axil_bresp[NUMBER_SLAVE];
    logic [NUMBER_SLAVE-1:0] s_axil_bvalid;
    logic [NUMBER_SLAVE-1:0] s_axil_bready;

    // Подключение кроссбара
    axil_crossbar_wr #(
        .NUMBER_MASTER(NUMBER_MASTER),
        .NUMBER_SLAVE(NUMBER_SLAVE),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
    ) axil_crossbar_wr_inst (
        .grant_wr(grant_wr),
        .grant_wr_trans(grant_wr_trans),
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

    initial begin
        // Инициализация сигналов
        grant_wr = '{default: '0};
        grant_wr_trans = '{default: '0};
        
        // Стимулы для мастера 0
        m_axil_awaddr[0] = 8'hAA;
        m_axil_awvalid[0] = 1;
        m_axil_wdata[0] = 8'h55;
        m_axil_wstrb[0] = 1;
        m_axil_wvalid[0] = 1;
        m_axil_bready[0] = 1;

        // Стимулы для мастера 1
        m_axil_awaddr[1] = 8'hBB;
        m_axil_awvalid[1] = 1;
        m_axil_wdata[1] = 8'hCC;
        m_axil_wstrb[1] = 1;
        m_axil_wvalid[1] = 1;
        m_axil_bready[1] = 1;

        // Симуляция для слейва 0
        s_axil_awready[0] = 1;
        s_axil_wready[0] = 1;
        s_axil_bresp[0] = 2'b00;
        s_axil_bvalid[0] = 1;

        // Симуляция для слейва 1
        s_axil_awready[1] = 1;
        s_axil_wready[1] = 1;
        s_axil_bresp[1] = 2'b01;
        s_axil_bvalid[1] = 1;

        // Симуляция для слейва 2
        s_axil_awready[2] = 1;
        s_axil_wready[2] = 1;
        s_axil_bresp[2] = 2'b10;
        s_axil_bvalid[2] = 1;

        // Симуляция для слейва 2
        s_axil_awready[3] = 1;
        s_axil_wready[3] = 1;
        s_axil_bresp[3] = 2'b11;
        s_axil_bvalid[3] = 1;
    end

    initial
    begin
        #100;

        grant_wr[0] = 2'b1;
        grant_wr[1] = 2'b0;
        grant_wr[2] = 2'b0;
        grant_wr[3] = 2'b0;        

        #1000;

        $finish;
    end

endmodule