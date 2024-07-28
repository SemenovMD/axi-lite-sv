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

    logic   [NUMBER_MASTER-1:0]                 slv_invalid_wr;

    // Channel Write Address
    logic   [AXI_ADDR_WIDTH-1:0]                m_axil_awaddr_1         [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]                 m_axil_awvalid_1;
    logic   [NUMBER_MASTER-1:0]                 m_axil_awready_1;

    // Channel Write Data
    logic   [AXI_ADDR_WIDTH-1:0]                m_axil_wdata_1          [NUMBER_MASTER];
    logic   [AXI_DATA_WIDTH/8-1:0]              m_axil_wstrb_1          [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]                 m_axil_wvalid_1;
    logic   [NUMBER_MASTER-1:0]                 m_axil_wready_1;

    // Channel Write Response
    logic   [1:0]                               m_axil_bresp_1          [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]                 m_axil_bvalid_1;
    logic   [NUMBER_MASTER-1:0]                 m_axil_bready_1;

    // Channel Write Address
    logic   [AXI_ADDR_WIDTH-1:0]                m_axil_awaddr_2         [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]                 m_axil_awvalid_2;
    logic   [NUMBER_MASTER-1:0]                 m_axil_awready_2;

    // Channel Write Data
    logic   [AXI_ADDR_WIDTH-1:0]                m_axil_wdata_2          [NUMBER_MASTER];
    logic   [AXI_DATA_WIDTH/8-1:0]              m_axil_wstrb_2          [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]                 m_axil_wvalid_2;
    logic   [NUMBER_MASTER-1:0]                 m_axil_wready_2;

    // Channel Write Response
    logic   [1:0]                               m_axil_bresp_2          [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]                 m_axil_bvalid_2;
    logic   [NUMBER_MASTER-1:0]                 m_axil_bready_2;

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

    logic   [NUMBER_MASTER-1:0]                  slv_invalid_rd;

    // Channel Read Address
    logic   [AXI_ADDR_WIDTH-1:0]                m_axil_araddr_1         [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]                 m_axil_arvalid_1;
    logic   [NUMBER_MASTER-1:0]                 m_axil_arready_1;

    // Channel Read Data
    logic   [AXI_ADDR_WIDTH-1:0]                m_axil_rdata_1          [NUMBER_MASTER];
    logic   [1:0]                               m_axil_rresp_1          [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]                 m_axil_rvalid_1;
    logic   [NUMBER_MASTER-1:0]                 m_axil_rready_1;

    // Channel Read Address
    logic   [AXI_ADDR_WIDTH-1:0]                m_axil_araddr_2         [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]                 m_axil_arvalid_2;
    logic   [NUMBER_MASTER-1:0]                 m_axil_arready_2;

    // Channel Read Data
    logic   [AXI_ADDR_WIDTH-1:0]                m_axil_rdata_2          [NUMBER_MASTER];
    logic   [1:0]                               m_axil_rresp_2          [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]                 m_axil_rvalid_2;
    logic   [NUMBER_MASTER-1:0]                 m_axil_rready_2;

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel WRITE
    ////////////////////////////////////////////////////////////////////////////////////////////////  

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
        for (i = 0; i < NUMBER_MASTER; i++) begin : axil_decoder_addr_wr
            axil_decoder_addr_wr #(
                .NUMBER_SLAVE(NUMBER_SLAVE),
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
                .AXI_ADDR_OFFSET(AXI_ADDR_OFFSET),
                .AXI_ADDR_RANGE(AXI_ADDR_RANGE)
            ) 
            axil_decoder_addr_wr_inst
            (
                .aclk(aclk),
                .aresetn(aresetn),
                .addr(m_axil_awaddr[i]),
                .slv_valid(slv_select_wire[i]),
                .slv_invalid(slv_invalid_wr[i]),
                .m_axil_awvalid(m_axil_awvalid[i]),
                .m_axil_wvalid(m_axil_wvalid[i]),
                .m_axil_bvalid(m_axil_bvalid[i]),
                .m_axil_bready(m_axil_bready[i])
            );
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : axil_mux_wr
            axil_mux_wr #(
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
            )
            axil_mux_wr_inst
            (
                .slv_invalid(slv_invalid_wr[i]),
                .m_axil_awaddr_0(m_axil_awaddr[i]),
                .m_axil_awvalid_0(m_axil_awvalid[i]),
                .m_axil_awready_0(m_axil_awready[i]),
                .m_axil_wdata_0(m_axil_wdata[i]),
                .m_axil_wstrb_0(m_axil_wstrb[i]),
                .m_axil_wvalid_0(m_axil_wvalid[i]),
                .m_axil_wready_0(m_axil_wready[i]),
                .m_axil_bresp_0(m_axil_bresp[i]),
                .m_axil_bvalid_0(m_axil_bvalid[i]),
                .m_axil_bready_0(m_axil_bready[i]),
                .m_axil_awaddr_1(m_axil_awaddr_1[i]),
                .m_axil_awvalid_1(m_axil_awvalid_1[i]),
                .m_axil_awready_1(m_axil_awready_1[i]),
                .m_axil_wdata_1(m_axil_wdata_1[i]),
                .m_axil_wstrb_1(m_axil_wstrb_1[i]),
                .m_axil_wvalid_1(m_axil_wvalid_1[i]),
                .m_axil_wready_1(m_axil_wready_1[i]), 
                .m_axil_bresp_1(m_axil_bresp_1[i]),
                .m_axil_bvalid_1(m_axil_bvalid_1[i]),
                .m_axil_bready_1(m_axil_bready_1[i]),
                .m_axil_awaddr_2(m_axil_awaddr_2[i]),
                .m_axil_awvalid_2(m_axil_awvalid_2[i]),
                .m_axil_awready_2(m_axil_awready_2[i]),
                .m_axil_wdata_2(m_axil_wdata_2[i]),
                .m_axil_wstrb_2(m_axil_wstrb_2[i]),
                .m_axil_wvalid_2(m_axil_wvalid_2[i]),
                .m_axil_wready_2(m_axil_wready_2[i]),
                .m_axil_bresp_2(m_axil_bresp_2[i]),
                .m_axil_bvalid_2(m_axil_bvalid_2[i]),
                .m_axil_bready_2(m_axil_bready_2[i])
            );
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : axil_response_addr_invalid_wr
            axil_response_addr_invalid_wr #(
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
            )
            axil_response_addr_invalid_wr 
            (
                .aclk(aclk),
                .aresetn(aresetn),
                .slv_invalid(slv_invalid_wr[i]),
                .s_axil_awaddr(m_axil_awaddr_2[i]),
                .s_axil_awvalid(m_axil_awvalid_2[i]),
                .s_axil_wdata(m_axil_wvalid_2[i]),
                .s_axil_wstrb(m_axil_wstrb_2[i]),
                .s_axil_wvalid(m_axil_wvalid_2[i]),
                .s_axil_awready(m_axil_awready_2[i]),
                .s_axil_wready(m_axil_wready_2[i]),
                .s_axil_bresp(m_axil_bresp_2[i]),
                .s_axil_bvalid(m_axil_bvalid_2[i]),
                .s_axil_bready(m_axil_bready_2[i])
            );
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
                .m_axil_awaddr(m_axil_awaddr_1),
                .m_axil_awvalid(m_axil_awvalid_1),
                .m_axil_wdata(m_axil_wdata_1),
                .m_axil_wstrb(m_axil_wstrb_1),
                .m_axil_wvalid(m_axil_wvalid_1),
                .m_axil_bready(m_axil_bready_1),
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
                .m_axil_awready(m_axil_awready_1[i]),
                .m_axil_wready(m_axil_wready_1[i]),
                .m_axil_bresp(m_axil_bresp_1[i]),
                .m_axil_bvalid(m_axil_bvalid_1[i]),
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
        for (i = 0; i < NUMBER_MASTER; i++) begin : gen_rd_1
            for (j = 0; j < NUMBER_SLAVE; j++) begin : gen_rd_2
                assign slv_select_wire_rd_tr[j][i] = slv_select_wire_rd[i][j];
                assign m_axil_rready_wire[j][i] = m_axil_rready[i];
                assign grant_rd_wire_tr[i][j]   = grant_rd_wire[j][i];
            end
        end
    endgenerate

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
                .aclk(aclk),
                .aresetn(aresetn),
                .addr(m_axil_araddr[i]),
                .slv_valid(slv_select_wire_rd[i]),
                .slv_invalid(slv_invalid_rd[i]),
                .m_axil_arvalid(m_axil_arvalid[i]),
                .m_axil_rvalid(m_axil_rvalid[i]),
                .m_axil_rready(m_axil_rready[i])
            );
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : axil_mux_rd
            axil_mux_rd #(
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
            )
            axil_mux_rd_inst
            (
                .slv_invalid(slv_invalid_rd[i]),
                .m_axil_araddr_0(m_axil_araddr[i]),
                .m_axil_arvalid_0(m_axil_arvalid[i]),
                .m_axil_arready_0(m_axil_arready[i]),
                .m_axil_rdata_0(m_axil_rdata[i]),
                .m_axil_rresp_0(m_axil_rresp[i]),
                .m_axil_rvalid_0(m_axil_rvalid[i]),
                .m_axil_rready_0(m_axil_rready[i]),
                .m_axil_araddr_1(m_axil_araddr_1[i]),
                .m_axil_arvalid_1(m_axil_arvalid_1[i]),
                .m_axil_arready_1(m_axil_arready_1[i]),
                .m_axil_rdata_1(m_axil_rdata_1[i]),
                .m_axil_rresp_1(m_axil_rresp_1[i]),
                .m_axil_rvalid_1(m_axil_rvalid_1[i]),
                .m_axil_rready_1(m_axil_rready_1[i]),
                .m_axil_araddr_2(m_axil_araddr_2[i]),
                .m_axil_arvalid_2(m_axil_arvalid_2[i]),
                .m_axil_arready_2(m_axil_arready_2[i]),
                .m_axil_rdata_2(m_axil_rdata_2[i]),
                .m_axil_rresp_2(m_axil_rresp_2[i]),
                .m_axil_rvalid_2(m_axil_rvalid_2[i]),
                .m_axil_rready_2(m_axil_rready_2[i])
            );
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : axil_response_addr_invalid_rd
            axil_response_addr_invalid_rd #(
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
            )
            axil_response_addr_invalid_wr 
            (
                .aclk(aclk),
                .aresetn(aresetn),
                .slv_invalid(slv_invalid_rd[i]),
                .s_axil_araddr(m_axil_araddr_2[i]),
                .s_axil_arvalid(m_axil_arvalid_2[i]),
                .s_axil_arready(m_axil_arready_2[i]),
                .s_axil_rdata(m_axil_rdata_2[i]),
                .s_axil_rresp(m_axil_rresp_2[i]),
                .s_axil_rvalid(m_axil_rvalid_2[i]),
                .s_axil_rready(m_axil_rready_2[i])
            );
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
                .m_axil_araddr(m_axil_araddr_1),
                .m_axil_arvalid(m_axil_arvalid_1),
                .m_axil_rready(m_axil_rready_1),
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
                .m_axil_arready(m_axil_arready_1[i]),
                .m_axil_rdata(m_axil_rdata_1[i]),
                .m_axil_rresp(m_axil_rresp_1[i]),
                .m_axil_rvalid(m_axil_rvalid_1[i]),
                .s_axil_arready(s_axil_arready),
                .s_axil_rdata(s_axil_rdata),
                .s_axil_rresp(s_axil_rresp),
                .s_axil_rvalid(s_axil_rvalid)
            );
        end
    endgenerate

endmodule