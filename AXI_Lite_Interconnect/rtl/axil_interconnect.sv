module axil_interconnect
#(
    parameter                               NUMBER_MASTER                   = 2,
    parameter                               NUMBER_SLAVE                    = 4,
    parameter                               AXI_DATA_WIDTH                  = 32,   
    parameter                               AXI_ADDR_WIDTH                  = 32,
    parameter   bit [AXI_ADDR_WIDTH-1:0]    AXI_ADDR_OFFSET [NUMBER_SLAVE]  = '{default: '0},
    parameter   bit [AXI_ADDR_WIDTH-1:0]    AXI_ADDR_RANGE  [NUMBER_SLAVE]  = '{default: 1}
)

(
    input   logic                               aclk,
    input   logic                               aresetn,

    // Channel Write Address Master
    input   logic   [AXI_ADDR_WIDTH-1:0]        m_axil_awaddr           [NUMBER_MASTER],
    input   logic   [NUMBER_MASTER-1:0]         m_axil_awvalid,
    output  logic   [NUMBER_MASTER-1:0]         m_axil_awready,

    // Channel Write Data Master
    input   logic   [AXI_ADDR_WIDTH-1:0]        m_axil_wdata            [NUMBER_MASTER],
    input   logic   [AXI_DATA_WIDTH/8-1:0]      m_axil_wstrb            [NUMBER_MASTER],
    input   logic   [NUMBER_MASTER-1:0]         m_axil_wvalid,
    output  logic   [NUMBER_MASTER-1:0]         m_axil_wready,

    // Channel Write Response Master
    output  logic   [1:0]                       m_axil_bresp            [NUMBER_MASTER],
    output  logic   [NUMBER_MASTER-1:0]         m_axil_bvalid,
    input   logic   [NUMBER_MASTER-1:0]         m_axil_bready,

    // Channel Write Address Slave
    output  logic   [AXI_ADDR_WIDTH-1:0]        s_axil_awaddr           [NUMBER_SLAVE],
    output  logic   [NUMBER_SLAVE-1:0]          s_axil_awvalid,
    input   logic   [NUMBER_SLAVE-1:0]          s_axil_awready,

    // Channel Write Data Slave
    output  logic   [AXI_ADDR_WIDTH-1:0]        s_axil_wdata            [NUMBER_SLAVE],
    output  logic   [AXI_DATA_WIDTH/8-1:0]      s_axil_wstrb            [NUMBER_SLAVE],
    output  logic   [NUMBER_SLAVE-1:0]          s_axil_wvalid,
    input   logic   [NUMBER_SLAVE-1:0]          s_axil_wready,

    // Channel Write Response Slave
    input   logic   [1:0]                       s_axil_bresp            [NUMBER_SLAVE],
    input   logic   [NUMBER_SLAVE-1:0]          s_axil_bvalid,
    output  logic   [NUMBER_SLAVE-1:0]          s_axil_bready,

    output  logic   [NUMBER_MASTER-1:0]         addr_illegal
);

    logic   [NUMBER_SLAVE-1:0]                  slv_select_wire         [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]                 slv_select_wire_tr      [NUMBER_SLAVE];

    logic   [NUMBER_MASTER-1:0]                 grant_wr_wire           [NUMBER_SLAVE];
    logic   [NUMBER_SLAVE-1:0]                  grant_wr_wire_tr        [NUMBER_MASTER];

    logic   [$clog2(NUMBER_MASTER)-1:0]         grant_wr_cdr_wire       [NUMBER_SLAVE];
    logic   [$clog2(NUMBER_SLAVE)-1:0]          grant_wr_cdr_wire_tr    [NUMBER_MASTER];   

    logic   [NUMBER_MASTER-1:0]                 m_axil_bready_wire      [NUMBER_SLAVE];

    genvar i, j;

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : axil_decoder_addr_wr
            axil_decoder_addr_wr #(
                .NUMBER_SLAVE(NUMBER_SLAVE),
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
                .AXI_ADDR_OFFSET(AXI_ADDR_OFFSET),
                .AXI_ADDR_RANGE(AXI_ADDR_RANGE)
            ) 
            axil_decoder_addr_wr_inst
            (
                .addr(m_axil_awaddr[i]),
                .slv_select(slv_select_wire[i]),
                .addr_illegal(addr_illegal[i]),
                .m_axil_awvalid(m_axil_awvalid[i]),
                .m_axil_wvalid(m_axil_wvalid[i])
            );
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : gen_tr_1
            for (j = 0; j < NUMBER_SLAVE; j++) begin : gen_tr_2
                assign slv_select_wire_tr[j][i] = slv_select_wire[i][j];
                assign m_axil_bready_wire[j][i] = m_axil_bready[i];
                assign grant_wr_wire_tr[i][j]   = grant_wr_wire[j][i];
            end
        end
    endgenerate

    generate
        for (j = 0; j < NUMBER_MASTER; j++) begin : gen_tr_3
            always_comb
            begin
                grant_wr_cdr_wire_tr[j] = '0;

                for (int k = 0; k < NUMBER_SLAVE; k++) 
                begin
                    if (grant_wr_wire_tr[j][k])
                    begin
                        grant_wr_cdr_wire_tr[j] = k;
                    end
                end
            end
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_SLAVE; i++) begin : axil_arbiter_priority_wr
            axil_arbiter_priority_wr #(
                .NUMBER_MASTER(NUMBER_MASTER)
            )
            axil_arbiter_priority_wr_inst
            (
                .aclk(aclk),
                .aresetn(aresetn),
                .request_wr(slv_select_wire_tr[i]),
                .grant_wr(grant_wr_wire[i]),
                .grant_wr_cdr(grant_wr_cdr_wire[i]),
                .s_axil_bvalid(s_axil_bvalid[i]),
                .m_axil_bready(m_axil_bready_wire[i])
            );
        end
    endgenerate

    axil_crossbar_wr #

    (
        .NUMBER_MASTER(NUMBER_MASTER),
        .NUMBER_SLAVE(NUMBER_SLAVE),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
    )

    axil_crossbar_wr_inst

    (
        .grant_wr(grant_wr_wire),
        .grant_wr_trans(grant_wr_wire_tr),
        .grant_wr_cdr(grant_wr_cdr_wire),
        .grant_wr_cdr_trans(grant_wr_cdr_wire_tr),
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

endmodule
