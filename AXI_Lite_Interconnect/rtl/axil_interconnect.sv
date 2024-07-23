module axil_interconnect
#(
    parameter                               NUMBER_MASTER                   = 2,
    parameter                               NUMBER_SLAVE                    = 4,
    parameter                               AXI_DATA_WIDTH                  = 32,   
    parameter                               AXI_ADDR_WIDTH                  = 32,
    parameter   bit [AXI_ADDR_WIDTH-1:0]    AXI_ADDR_OFFSET [NUMBER_SLAVE]  = '{32'h1000_0000, 32'h2000_0000, 32'h3000_0000, 32'h4000_0000},
    parameter   bit [AXI_ADDR_WIDTH-1:0]    AXI_ADDR_RANGE  [NUMBER_SLAVE]  = '{32'h0000_FFFF, 32'h0000_FFFF, 32'h0000_FFFF, 32'h0000_FFFF}
)

(
    input   logic                               aclk,
    input   logic                               aresetn,

    // Channel Write Address Master
    input   logic   [AXI_ADDR_WIDTH-1:0]        m_axil_awaddr   [NUMBER_MASTER],
    input   logic   [NUMBER_MASTER-1:0]         m_axil_awvalid,
    output  logic   [NUMBER_MASTER-1:0]         m_axil_awready,

    // Channel Write Data Master
    input   logic   [AXI_ADDR_WIDTH-1:0]        m_axil_wdata    [NUMBER_MASTER],
    input   logic   [AXI_DATA_WIDTH/8-1:0]      m_axil_wstrb    [NUMBER_MASTER],
    input   logic   [NUMBER_MASTER-1:0]         m_axil_wvalid,
    output  logic   [NUMBER_MASTER-1:0]         m_axil_wready,

    // Channel Write Response Master
    output  logic   [1:0]                       m_axil_bresp    [NUMBER_MASTER],
    output  logic   [NUMBER_MASTER-1:0]         m_axil_bvalid,
    input   logic   [NUMBER_MASTER-1:0]         m_axil_bready,

    // Channel Write Address Slave
    output  logic   [AXI_ADDR_WIDTH-1:0]        s_axil_awaddr   [NUMBER_SLAVE],
    output  logic   [NUMBER_SLAVE-1:0]          s_axil_awvalid,
    input   logic   [NUMBER_SLAVE-1:0]          s_axil_awready,

    // Channel Write Data Slave
    output  logic   [AXI_ADDR_WIDTH-1:0]        s_axil_wdata    [NUMBER_SLAVE],
    output  logic   [AXI_DATA_WIDTH/8-1:0]      s_axil_wstrb    [NUMBER_SLAVE],
    output  logic   [NUMBER_SLAVE-1:0]          s_axil_wvalid,
    input   logic   [NUMBER_SLAVE-1:0]          s_axil_wready,

    // Channel Write Response Slave
    input   logic   [1:0]                       s_axil_bresp    [NUMBER_SLAVE],
    input   logic   [NUMBER_SLAVE-1:0]          s_axil_bvalid,
    output  logic   [NUMBER_SLAVE-1:0]          s_axil_bready,

    input   logic   [AXI_ADDR_WIDTH-1:0]        addr_wire       [NUMBER_MASTER],
    output  logic   [NUMBER_MASTER-1:0]         addr_illegal_wire,

    output  logic   [$clog2(NUMBER_MASTER)-1:0] grant_wr_wire   [NUMBER_SLAVE]
);

    logic   [NUMBER_SLAVE-1:0]      slv_select_wire         [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]     slv_select_wire_trans   [NUMBER_SLAVE];

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
                .addr(addr_wire[i]),
                .slv_select(slv_select_wire[i]),
                .addr_illegal(addr_illegal_wire[i])
            );
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : gen_tr_1
            for (j = 0; j < NUMBER_SLAVE; j++) begin : gen_tr_2
                assign slv_select_wire_trans[j][i] = slv_select_wire[i][j];
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
                .request_wr(slv_select_wire_trans[i]),
                .grant_wr(grant_wr_wire[i])
            );
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_SLAVE; i++) begin : axil_crossbar_wr_gen
            logic [NUMBER_MASTER-1:0] crossbar_awready;
            logic [NUMBER_MASTER-1:0] crossbar_wready;
            logic [1:0]               crossbar_bresp [NUMBER_MASTER];
            logic [NUMBER_MASTER-1:0] crossbar_bvalid;

            axil_crossbar_wr #(
                .NUMBER_MASTER(NUMBER_MASTER),
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
            )
            axil_crossbar_wr_inst
            (
                .grant_wr(grant_wr_wire[i]),
                .m_axil_awaddr(m_axil_awaddr),
                .m_axil_awvalid(m_axil_awvalid),
                .m_axil_awready(crossbar_awready),
                .m_axil_wdata(m_axil_wdata),
                .m_axil_wstrb(m_axil_wstrb),
                .m_axil_wvalid(m_axil_wvalid),
                .m_axil_wready(crossbar_wready),
                .m_axil_bresp(crossbar_bresp),
                .m_axil_bvalid(crossbar_bvalid),
                .m_axil_bready(m_axil_bready),

                .s_axil_awaddr(s_axil_awaddr[i]),
                .s_axil_awvalid(s_axil_awvalid[i]),
                .s_axil_awready(s_axil_awready[i]),
                .s_axil_wdata(s_axil_wdata[i]),
                .s_axil_wstrb(s_axil_wstrb[i]),
                .s_axil_wvalid(s_axil_wvalid[i]),
                .s_axil_wready(s_axil_wready[i]),
                .s_axil_bresp(s_axil_bresp[i]),
                .s_axil_bvalid(s_axil_bvalid[i]),
                .s_axil_bready(s_axil_bready[i])
            );

            // Ensure correct indexing
            for (j = 0; j < NUMBER_MASTER; j++) begin : connect_master_ports
                if (j < NUMBER_MASTER) begin
                    assign m_axil_awready[j] = crossbar_awready[j];
                    assign m_axil_wready[j] = crossbar_wready[j];
                    assign m_axil_bresp[j] = crossbar_bresp[j];
                    assign m_axil_bvalid[j] = crossbar_bvalid[j];
                end
            end
        end
    endgenerate
endmodule
