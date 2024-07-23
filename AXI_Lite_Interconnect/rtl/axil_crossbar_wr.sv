module axil_crossbar_wr
#(
    parameter   NUMBER_MASTER   = 2,
    parameter   NUMBER_SLAVE    = 4,
    parameter   AXI_DATA_WIDTH  = 8,
    parameter   AXI_ADDR_WIDTH  = 8      
)

(
    input   logic   [NUMBER_MASTER-1:0]             grant_wr            [NUMBER_SLAVE],

    // Channel Write Address Master
    input   logic   [AXI_ADDR_WIDTH-1:0]            m_axil_awaddr       [NUMBER_MASTER],
    input   logic   [NUMBER_MASTER-1:0]             m_axil_awvalid,
    output  logic   [NUMBER_MASTER-1:0]             m_axil_awready,

    // Channel Write Data Master
    input   logic   [AXI_DATA_WIDTH-1:0]            m_axil_wdata        [NUMBER_MASTER],
    input   logic   [AXI_DATA_WIDTH/8-1:0]          m_axil_wstrb        [NUMBER_MASTER],
    input   logic   [NUMBER_MASTER-1:0]             m_axil_wvalid,
    output  logic   [NUMBER_MASTER-1:0]             m_axil_wready,

    // Channel Write Response Master
    output  logic   [1:0]                           m_axil_bresp        [NUMBER_MASTER],
    output  logic   [NUMBER_MASTER-1:0]             m_axil_bvalid,
    input   logic   [NUMBER_MASTER-1:0]             m_axil_bready,

    // Channel Write Address Slave
    output  logic   [AXI_ADDR_WIDTH-1:0]            s_axil_awaddr       [NUMBER_SLAVE],
    output  logic   [NUMBER_SLAVE-1:0]              s_axil_awvalid,
    input   logic   [NUMBER_SLAVE-1:0]              s_axil_awready,

    // Channel Write Data Slave
    output  logic   [AXI_DATA_WIDTH-1:0]            s_axil_wdata        [NUMBER_SLAVE],
    output  logic   [AXI_DATA_WIDTH/8-1:0]          s_axil_wstrb        [NUMBER_SLAVE],
    output  logic   [NUMBER_SLAVE-1:0]              s_axil_wvalid,
    input   logic   [NUMBER_SLAVE-1:0]              s_axil_wready,

    // Channel Write Response Slave
    input   logic   [1:0]                           s_axil_bresp        [NUMBER_SLAVE],
    input   logic   [NUMBER_SLAVE-1:0]              s_axil_bvalid,
    output  logic   [NUMBER_SLAVE-1:0]              s_axil_bready
);

    logic   [NUMBER_SLAVE-1:0]                      grant_wr_trans      [NUMBER_MASTER];

    logic   [$clog2(NUMBER_MASTER)-1:0]             grant_wr_cdr        [NUMBER_SLAVE];
    logic   [$clog2(NUMBER_SLAVE)-1:0]              grant_wr_cdr_trans  [NUMBER_MASTER];

    genvar i, j;

    generate
        for (i = 0; i < NUMBER_SLAVE; i++) begin : gen_grant_wr_cdr
            always_comb 
            begin
                grant_wr_cdr[i] = '0;
                
                for (int k = 0; k < NUMBER_MASTER; k++) 
                begin
                    if (grant_wr[i][k]) begin
                        grant_wr_cdr[i] = k;
                        break;
                    end
                end
            end
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : gen_master_1
            for (j = 0; j < NUMBER_SLAVE; j++) begin : gen_slave_1
                assign grant_wr_trans[j][i] = grant_wr[i][j];
            end
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : gen_master_2
            for (j = 0; j < NUMBER_SLAVE; j++) begin : gen_slave_2
                assign grant_wr_cdr_trans[j][i] = grant_wr_cdr[i][j];
            end
        end
    endgenerate

    // Generate logic for each slave
    generate
        for (i = 0; i < NUMBER_SLAVE; i++) begin : gen_slave
            always_comb
            begin
                s_axil_awaddr[i]  = '0;
                s_axil_awvalid[i] = 0;
                s_axil_wdata[i]   = '0;
                s_axil_wstrb[i]   = '0;
                s_axil_wvalid[i]  = 0;
                s_axil_bready[i]  = 0;

                if (|grant_wr[i])
                begin
                    s_axil_awaddr[i]  = m_axil_awaddr[grant_wr_cdr[i]];
                    s_axil_awvalid[i] = m_axil_awvalid[grant_wr_cdr[i]];
                    s_axil_wdata[i]   = m_axil_wdata[grant_wr_cdr[i]];
                    s_axil_wstrb[i]   = m_axil_wstrb[grant_wr_cdr[i]];
                    s_axil_wvalid[i]  = m_axil_wvalid[grant_wr_cdr[i]];
                    s_axil_bready[i]  = m_axil_bready[grant_wr_cdr[i]];
                end
            end
        end
    endgenerate

    // Generate logic for each master
    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : gen_master
            always_comb
            begin
                m_axil_awready[i]  = 0;
                m_axil_wready[i]   = 0;
                m_axil_bresp[i]    = '0;
                m_axil_bvalid[i]   = 0;

                if (|grant_wr_trans[i])
                begin
                    m_axil_awready[i] = s_axil_awready[grant_wr_cdr_trans[i]];
                    m_axil_wready[i]  = s_axil_wready[grant_wr_cdr_trans[i]];
                    m_axil_bresp[i]   = s_axil_bresp[grant_wr_cdr_trans[i]];
                    m_axil_bvalid[i]  = s_axil_bvalid[grant_wr_cdr_trans[i]];
                end
            end
        end
    endgenerate

endmodule
