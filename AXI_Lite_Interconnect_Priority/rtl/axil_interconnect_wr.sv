module axil_interconnect_wr
    
    import axil_pkg ::*;

(
    // Global Signals
    input   logic                               aclk,
    input   logic                               aresetn,

    // Channel Write Master Address
    input   logic   [AXI_ADDR_WIDTH-1:0]        m_axil_awaddr           [NUMBER_MASTER],
    input   logic   [NUMBER_MASTER-1:0]         m_axil_awvalid,
    output  logic   [NUMBER_MASTER-1:0]         m_axil_awready,

    // Channel Write Master Data
    input   logic   [AXI_ADDR_WIDTH-1:0]        m_axil_wdata            [NUMBER_MASTER],
    input   logic   [AXI_DATA_WIDTH/8-1:0]      m_axil_wstrb            [NUMBER_MASTER],
    input   logic   [NUMBER_MASTER-1:0]         m_axil_wvalid,
    output  logic   [NUMBER_MASTER-1:0]         m_axil_wready,

    // Channel Write Master Response
    output  logic   [1:0]                       m_axil_bresp            [NUMBER_MASTER],
    output  logic   [NUMBER_MASTER-1:0]         m_axil_bvalid,
    input   logic   [NUMBER_MASTER-1:0]         m_axil_bready,

    // Channel Write Slave Address
    output  logic   [AXI_ADDR_WIDTH-1:0]        s_axil_awaddr           [NUMBER_SLAVE+1],
    output  logic   [NUMBER_SLAVE:0]            s_axil_awvalid,
    input   logic   [NUMBER_SLAVE:0]            s_axil_awready,

    // Channel Write Slave Data
    output  logic   [AXI_ADDR_WIDTH-1:0]        s_axil_wdata            [NUMBER_SLAVE+1],
    output  logic   [AXI_DATA_WIDTH/8-1:0]      s_axil_wstrb            [NUMBER_SLAVE+1],
    output  logic   [NUMBER_SLAVE:0]            s_axil_wvalid,
    input   logic   [NUMBER_SLAVE:0]            s_axil_wready,

    // Channel Write Slave Response
    input   logic   [1:0]                       s_axil_bresp            [NUMBER_SLAVE+1],
    input   logic   [NUMBER_SLAVE:0]            s_axil_bvalid,
    output  logic   [NUMBER_SLAVE:0]            s_axil_bready
);

    genvar i, j;

    logic   [NUMBER_SLAVE:0]                    slv_select_wire         [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]                 slv_select_wire_tr      [NUMBER_SLAVE+1];

    logic   [NUMBER_MASTER-1:0]                 grant_wr_wire           [NUMBER_SLAVE+1];
    logic   [NUMBER_SLAVE:0]                  	grant_wr_wire_tr        [NUMBER_MASTER];

    logic   [$clog2(NUMBER_MASTER)-1:0]         grant_wr_cdr_wire       [NUMBER_SLAVE+1];
    logic   [$clog2(NUMBER_SLAVE+1)-1:0]        grant_wr_cdr_wire_tr    [NUMBER_MASTER];   

    logic   [NUMBER_MASTER-1:0]                 m_axil_bready_wire      [NUMBER_SLAVE+1]; 

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : trans_master_wr
            for (j = 0; j < NUMBER_SLAVE+1; j++) begin : trans_slave_wr
                assign slv_select_wire_tr[j][i] = slv_select_wire[i][j];
                assign m_axil_bready_wire[j][i] = m_axil_bready[i];
                assign grant_wr_wire_tr[i][j]   = grant_wr_wire[j][i];
            end
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : axil_decoder_addr_wr
            axil_decoder_addr_wr axil_decoder_addr_wr_inst
            (
                .aclk(aclk),
                .aresetn(aresetn),
                .addr(m_axil_awaddr[i]),
                .slv_valid(slv_select_wire[i]),
                .m_axil_awvalid(m_axil_awvalid[i]),
                .m_axil_wvalid(m_axil_wvalid[i]),
                .m_axil_bvalid(m_axil_bvalid[i]),
                .m_axil_bready(m_axil_bready[i])
            );
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_SLAVE; i++) begin : axil_arbiter_priority_wr
            axil_arbiter_priority_wr axil_arbiter_priority_wr_inst
            (
                .aclk(aclk),
                .aresetn(aresetn),
                .request_wr(slv_select_wire_tr[i]),
                .grant_wr(grant_wr_wire[i]),
                .s_axil_bvalid(s_axil_bvalid[i]),
                .m_axil_bready(m_axil_bready_wire[i])
            );
        end
    endgenerate

    axil_arbiter_priority_wr axil_arbiter_priority_wr_inst_invalid
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .request_wr(slv_select_wire_tr[NUMBER_SLAVE]),
        .grant_wr(grant_wr_wire[NUMBER_SLAVE]),
        .s_axil_bvalid(s_axil_bvalid[NUMBER_SLAVE]),
        .m_axil_bready(m_axil_bready_wire[NUMBER_SLAVE])
    );

    generate
        for (i = 0; i < NUMBER_SLAVE; i++) begin : axil_crossbar_ms_wr
            axil_crossbar_ms_wr axil_crossbar_ms_wr_inst
            (
                .grant_wr(grant_wr_wire[i]),
                .m_axil_awaddr(m_axil_awaddr),
                .m_axil_awvalid(m_axil_awvalid),
                .m_axil_wdata(m_axil_wdata),
                .m_axil_wstrb(m_axil_wstrb),
                .m_axil_wvalid(m_axil_wvalid),
                .m_axil_bready(m_axil_bready),
                .s_axil_awaddr(s_axil_awaddr[i]),
                .s_axil_awvalid(s_axil_awvalid[i]),
                .s_axil_wdata(s_axil_wdata[i]),
                .s_axil_wstrb(s_axil_wstrb[i]),
                .s_axil_wvalid(s_axil_wvalid[i]),
                .s_axil_bready(s_axil_bready[i])
            );
        end
    endgenerate

    axil_crossbar_ms_wr axil_crossbar_ms_wr_inst_invalid
    (
        .grant_wr(grant_wr_wire[NUMBER_SLAVE]),
        .m_axil_awaddr(m_axil_awaddr),
        .m_axil_awvalid(m_axil_awvalid),
        .m_axil_wdata(m_axil_wdata),
        .m_axil_wstrb(m_axil_wstrb),
        .m_axil_wvalid(m_axil_wvalid),
        .m_axil_bready(m_axil_bready),
        .s_axil_awaddr(s_axil_awaddr[NUMBER_SLAVE]),
        .s_axil_awvalid(s_axil_awvalid[NUMBER_SLAVE]),
        .s_axil_wdata(s_axil_wdata[NUMBER_SLAVE]),
        .s_axil_wstrb(s_axil_wstrb[NUMBER_SLAVE]),
        .s_axil_wvalid(s_axil_wvalid[NUMBER_SLAVE]),
        .s_axil_bready(s_axil_bready[NUMBER_SLAVE])
    );

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : axil_crossbar_sm_wr
            axil_crossbar_sm_wr axil_crossbar_sm_wr_inst
            (
                .grant_wr_trans(grant_wr_wire_tr[i]),
                .m_axil_awready(m_axil_awready[i]),
                .m_axil_wready(m_axil_wready[i]),
                .m_axil_bresp(m_axil_bresp[i]),
                .m_axil_bvalid(m_axil_bvalid[i]),
                .s_axil_awready(s_axil_awready),
                .s_axil_wready(s_axil_wready),
                .s_axil_bresp(s_axil_bresp),
                .s_axil_bvalid(s_axil_bvalid)
            );
        end
    endgenerate

endmodule
