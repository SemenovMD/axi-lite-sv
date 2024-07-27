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
    // Globals Signals
    input   logic                               aclk,
    input   logic                               aresetn,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel WRITE Master
    ////////////////////////////////////////////////////////////////////////////////////////////////

    // Channel Write Address
    input   logic   [AXI_ADDR_WIDTH-1:0]        m_axil_awaddr           [NUMBER_MASTER],
    input   logic   [NUMBER_MASTER-1:0]         m_axil_awvalid,
    output  logic   [NUMBER_MASTER-1:0]         m_axil_awready,

    // Channel Write Data
    input   logic   [AXI_ADDR_WIDTH-1:0]        m_axil_wdata            [NUMBER_MASTER],
    input   logic   [AXI_DATA_WIDTH/8-1:0]      m_axil_wstrb            [NUMBER_MASTER],
    input   logic   [NUMBER_MASTER-1:0]         m_axil_wvalid,
    output  logic   [NUMBER_MASTER-1:0]         m_axil_wready,

    // Channel Write Response
    output  logic   [1:0]                       m_axil_bresp            [NUMBER_MASTER],
    output  logic   [NUMBER_MASTER-1:0]         m_axil_bvalid,
    input   logic   [NUMBER_MASTER-1:0]         m_axil_bready,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel WRITE Slave
    ////////////////////////////////////////////////////////////////////////////////////////////////

    // Channel Write Address
    output  logic   [AXI_ADDR_WIDTH-1:0]        s_axil_awaddr           [NUMBER_SLAVE],
    output  logic   [NUMBER_SLAVE-1:0]          s_axil_awvalid,
    input   logic   [NUMBER_SLAVE-1:0]          s_axil_awready,

    // Channel Write Data
    output  logic   [AXI_ADDR_WIDTH-1:0]        s_axil_wdata            [NUMBER_SLAVE],
    output  logic   [AXI_DATA_WIDTH/8-1:0]      s_axil_wstrb            [NUMBER_SLAVE],
    output  logic   [NUMBER_SLAVE-1:0]          s_axil_wvalid,
    input   logic   [NUMBER_SLAVE-1:0]          s_axil_wready,

    // Channel Write Response
    input   logic   [1:0]                       s_axil_bresp            [NUMBER_SLAVE],
    input   logic   [NUMBER_SLAVE-1:0]          s_axil_bvalid,
    output  logic   [NUMBER_SLAVE-1:0]          s_axil_bready,

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
    output  logic   [AXI_ADDR_WIDTH-1:0]        s_axil_araddr           [NUMBER_SLAVE],
    output  logic   [NUMBER_SLAVE-1:0]          s_axil_arvalid,
    input   logic   [NUMBER_SLAVE-1:0]          s_axil_arready,

    // Channel Read Data
    input   logic   [AXI_DATA_WIDTH-1:0]        s_axil_rdata            [NUMBER_SLAVE],
    input   logic   [1:0]                       s_axil_rresp            [NUMBER_SLAVE],
    input   logic   [NUMBER_SLAVE-1:0]          s_axil_rvalid,
    output  logic   [NUMBER_SLAVE-1:0]          s_axil_rready
);

    genvar i, j;

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel WRITE
    ////////////////////////////////////////////////////////////////////////////////////////////////

    logic   [NUMBER_SLAVE-1:0]                  slv_select_wire         [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]                 slv_select_wire_tr      [NUMBER_SLAVE];

    logic   [NUMBER_MASTER-1:0]                 grant_wr_wire           [NUMBER_SLAVE];
    logic   [NUMBER_SLAVE-1:0]                  grant_wr_wire_tr        [NUMBER_MASTER];

    logic   [$clog2(NUMBER_MASTER)-1:0]         grant_wr_cdr_wire       [NUMBER_SLAVE];
    logic   [$clog2(NUMBER_SLAVE)-1:0]          grant_wr_cdr_wire_tr    [NUMBER_MASTER];   

    logic   [NUMBER_MASTER-1:0]                 m_axil_bready_wire      [NUMBER_SLAVE];

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel READ
    ////////////////////////////////////////////////////////////////////////////////////////////////

    logic   [NUMBER_SLAVE-1:0]                  slv_select_wire_rd      [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]                 slv_select_wire_rd_tr   [NUMBER_SLAVE];

    logic   [NUMBER_MASTER-1:0]                 grant_rd_wire           [NUMBER_SLAVE];
    logic   [NUMBER_SLAVE-1:0]                  grant_rd_wire_tr        [NUMBER_MASTER];

    logic   [$clog2(NUMBER_MASTER)-1:0]         grant_rd_cdr_wire       [NUMBER_SLAVE];
    logic   [$clog2(NUMBER_SLAVE)-1:0]          grant_rd_cdr_wire_tr    [NUMBER_MASTER];   

    logic   [NUMBER_MASTER-1:0]                 m_axil_rready_wire      [NUMBER_SLAVE];

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel WRITE
    ////////////////////////////////////////////////////////////////////////////////////////////////  

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
                //.addr_illegal(addr_illegal[i]),
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
                //.grant_wr_cdr(grant_wr_cdr_wire[i]),
                .s_axil_bvalid(s_axil_bvalid[i]),
                .m_axil_bready(m_axil_bready_wire[i])
            );
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_SLAVE; i++) begin : axil_crossbar_ms_wr
            axil_crossbar_ms_wr #

            (
                .NUMBER_MASTER(NUMBER_MASTER),
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
            )

            axil_crossbar_ms_wr_inst

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

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : axil_crossbar_sm_wr
            axil_crossbar_sm_wr #

            (
                .NUMBER_SLAVE(NUMBER_SLAVE),
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
            )

            axil_crossbar_sm_wr_inst

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

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel READ
    ////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : axil_decoder_addr_rd
            axil_decoder_addr_rd #(
                .NUMBER_SLAVE(NUMBER_SLAVE),
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
                .AXI_ADDR_OFFSET(AXI_ADDR_OFFSET),
                .AXI_ADDR_RANGE(AXI_ADDR_RANGE)
            ) 
            axil_decoder_addr_rd_inst
            (
                .addr(m_axil_araddr[i]),
                .slv_select(slv_select_wire_rd[i]),
                //.addr_illegal(addr_illegal[i]),
                .m_axil_arvalid(m_axil_arvalid[i])
            );
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : gen_rd_1
            for (j = 0; j < NUMBER_SLAVE; j++) begin : gen_rd_2
                assign slv_select_wire_rd_tr[j][i] = slv_select_wire_rd[i][j];
                assign m_axil_rready_wire[j][i] = m_axil_rready[i];
                assign grant_rd_wire_tr[i][j]   = grant_rd_wire[j][i];
            end
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_SLAVE; i++) begin : axil_arbiter_priority_rd
            axil_arbiter_priority_rd #(
                .NUMBER_MASTER(NUMBER_MASTER)
            )
            axil_arbiter_priority_rd_inst
            (
                .aclk(aclk),
                .aresetn(aresetn),
                .request_rd(slv_select_wire_rd_tr[i]),
                .grant_rd(grant_rd_wire[i]),
                //.grant_wr_cdr(grant_wr_cdr_wire[i]),
                .s_axil_rvalid(s_axil_rvalid[i]),
                .m_axil_rready(m_axil_rready_wire[i])
            );
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_SLAVE; i++) begin : axil_crossbar_ms_rd
            axil_crossbar_ms_rd #

            (
                .NUMBER_MASTER(NUMBER_MASTER),
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
            )

            axil_crossbar_ms_rd_inst

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

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : axil_crossbar_sm_rd
            axil_crossbar_sm_rd #

            (
                .NUMBER_SLAVE(NUMBER_SLAVE),
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
            )

            axil_crossbar_sm_rd_inst

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
