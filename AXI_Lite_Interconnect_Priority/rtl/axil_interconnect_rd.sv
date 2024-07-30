module axil_interconnect_rd

    import axil_pkg ::*;

(
    // Globals Signals
    input   logic                               aclk,
    input   logic                               aresetn,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel READ Master
    ////////////////////////////////////////////////////////////////////////////////////////////////    

    // Channel Read Address
    input   logic   [AXI_ADDR_WIDTH-1:0]        m_axil_araddr           [NUMBER_MASTER],
    input   logic   [NUMBER_MASTER-1:0]         m_axil_arvalid,
    output  logic   [NUMBER_MASTER-1:0]         m_axil_arready,

    // Channel Read Data
    output  logic   [AXI_DATA_WIDTH-1:0]        m_axil_rdata            [NUMBER_MASTER],
    output  logic   [1:0]                       m_axil_rresp            [NUMBER_MASTER],
    output  logic   [NUMBER_MASTER-1:0]         m_axil_rvalid,
    input   logic   [NUMBER_MASTER-1:0]         m_axil_rready,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel READ Slave
    ////////////////////////////////////////////////////////////////////////////////////////////////

    // Channel Read Address
    output  logic   [AXI_ADDR_WIDTH-1:0]        s_axil_araddr           [NUMBER_SLAVE+1],
    output  logic   [NUMBER_SLAVE:0]            s_axil_arvalid,
    input   logic   [NUMBER_SLAVE:0]            s_axil_arready,

    // Channel Read Data
    input   logic   [AXI_DATA_WIDTH-1:0]        s_axil_rdata            [NUMBER_SLAVE+1],
    input   logic   [1:0]                       s_axil_rresp            [NUMBER_SLAVE+1],
    input   logic   [NUMBER_SLAVE:0]            s_axil_rvalid,
    output  logic   [NUMBER_SLAVE:0]            s_axil_rready
);

    genvar i, j;

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel READ
    ////////////////////////////////////////////////////////////////////////////////////////////////

    logic   [NUMBER_SLAVE:0]                    slv_select_wire_rd      [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]                 slv_select_wire_rd_tr   [NUMBER_SLAVE+1];

    logic   [NUMBER_MASTER-1:0]                 grant_rd_wire           [NUMBER_SLAVE+1];
    logic   [NUMBER_SLAVE:0]                    grant_rd_wire_tr        [NUMBER_MASTER];

    logic   [$clog2(NUMBER_MASTER)-1:0]         grant_rd_cdr_wire       [NUMBER_SLAVE+1];
    logic   [$clog2(NUMBER_SLAVE+1)-1:0]        grant_rd_cdr_wire_tr    [NUMBER_MASTER];   

    logic   [NUMBER_MASTER-1:0]                 m_axil_rready_wire      [NUMBER_SLAVE+1];

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel READ
    ////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : trans_master_rd
            for (j = 0; j < NUMBER_SLAVE+1; j++) begin : trans_slave_rd
                assign slv_select_wire_rd_tr[j][i] = slv_select_wire_rd[i][j];
                assign m_axil_rready_wire[j][i] = m_axil_rready[i];
                assign grant_rd_wire_tr[i][j]   = grant_rd_wire[j][i];
            end
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : axil_decoder_addr_rd
            axil_decoder_addr_rd axil_decoder_addr_rd_inst
            (
                .aclk(aclk),
                .aresetn(aresetn),
                .addr(m_axil_araddr[i]),
                .slv_valid(slv_select_wire_rd[i]),
                .m_axil_arvalid(m_axil_arvalid[i]),
                .m_axil_rvalid(m_axil_rvalid[i]),
                .m_axil_rready(m_axil_rready[i])
            );
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_SLAVE; i++) begin : axil_arbiter_priority_rd
            axil_arbiter_priority_rd axil_arbiter_priority_rd_inst
            (
                .aclk(aclk),
                .aresetn(aresetn),
                .request_rd(slv_select_wire_rd_tr[i]),
                .grant_rd(grant_rd_wire[i]),
                .s_axil_rvalid(s_axil_rvalid[i]),
                .m_axil_rready(m_axil_rready_wire[i])
            );
        end
    endgenerate

    axil_arbiter_priority_rd axil_arbiter_priority_rd_inst
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .request_rd(slv_select_wire_rd_tr[NUMBER_SLAVE]),
        .grant_rd(grant_rd_wire[NUMBER_SLAVE]),
        .s_axil_rvalid(s_axil_rvalid[NUMBER_SLAVE]),
        .m_axil_rready(m_axil_rready_wire[NUMBER_SLAVE])
    );

    generate
        for (i = 0; i < NUMBER_SLAVE; i++) begin : axil_crossbar_ms_rd
            axil_crossbar_ms_rd axil_crossbar_ms_rd_inst
            (
                .grant_rd(grant_rd_wire[i]),
                .m_axil_araddr(m_axil_araddr),
                .m_axil_arvalid(m_axil_arvalid),
                .m_axil_rready(m_axil_rready),
                .s_axil_araddr(s_axil_araddr[i]),
                .s_axil_arvalid(s_axil_arvalid[i]),
                .s_axil_rready(s_axil_rready[i])
            );
        end
    endgenerate

    axil_crossbar_ms_rd axil_crossbar_ms_rd_inst
    (
        .grant_rd(grant_rd_wire[NUMBER_SLAVE]),
        .m_axil_araddr(m_axil_araddr),
        .m_axil_arvalid(m_axil_arvalid),
        .m_axil_rready(m_axil_rready),
        .s_axil_araddr(s_axil_araddr[NUMBER_SLAVE]),
        .s_axil_arvalid(s_axil_arvalid[NUMBER_SLAVE]),
        .s_axil_rready(s_axil_rready[NUMBER_SLAVE])
    );

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : axil_crossbar_sm_rd
            axil_crossbar_sm_rd axil_crossbar_sm_rd_inst
            (
                .grant_rd_trans(grant_rd_wire_tr[i]),    
                .m_axil_arready(m_axil_arready[i]),
                .m_axil_rdata(m_axil_rdata[i]),
                .m_axil_rresp(m_axil_rresp[i]),
                .m_axil_rvalid(m_axil_rvalid[i]),
                .s_axil_arready(s_axil_arready),
                .s_axil_rdata(s_axil_rdata),
                .s_axil_rresp(s_axil_rresp),
                .s_axil_rvalid(s_axil_rvalid)
            );
        end
    endgenerate

endmodule