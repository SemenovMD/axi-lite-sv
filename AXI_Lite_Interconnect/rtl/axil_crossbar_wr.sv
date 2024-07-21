module axil_crossbar_wr
#(
    parameter   NUMBER_MASTER   = 2,
    parameter   AXI_DATA_WIDTH  = 32,
    parameter   AXI_ADDR_WIDTH  = 32      
)

(
    input   logic   [NUMBER_MASTER-1:0]         grant_wr,

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
    output  logic   [AXI_ADDR_WIDTH-1:0]        s_axil_awaddr,
    output  logic                               s_axil_awvalid,
    input   logic                               s_axil_awready,

    // Channel Write Data Slave
    output  logic   [AXI_ADDR_WIDTH-1:0]        s_axil_wdata,
    output  logic   [AXI_DATA_WIDTH/8-1:0]      s_axil_wstrb,
    output  logic                               s_axil_wvalid,
    input   logic                               s_axil_wready,

    // Channel Write Response Slave
    input   logic   [1:0]                       s_axil_bresp,
    input   logic                               s_axil_bvalid,
    output  logic                               s_axil_bready
);

    logic   [$clog2(NUMBER_MASTER)-1:0] grant_cdr;

    always_comb 
    begin
        grant_cdr = '0;

        for (int i = 0; i < NUMBER_MASTER-1; i++) 
        begin
            if (grant_wr[i]) 
            begin
                grant_cdr = i;
                break;
            end
        end
    end

    always_comb
    begin
        s_axil_awaddr           = '0;
        s_axil_awvalid          = 0;

        s_axil_wdata            = '0;
        s_axil_wstrb            = '0;
        s_axil_wvalid           = 0;
        s_axil_bready           = 0;

        for (int i = 0; i < NUMBER_MASTER; i++) 
        begin
            m_axil_awready[i]   = 0;
            m_axil_wready[i]    = 0;
            m_axil_bresp[i]     = '0;
            m_axil_bvalid[i]    = 0;
        end 

        s_axil_awaddr = m_axil_awaddr[grant_cdr];
        s_axil_awvalid = m_axil_awvalid[grant_cdr];
        m_axil_awready[grant_cdr] = s_axil_awready;

        s_axil_wdata = m_axil_wdata[grant_cdr];
        s_axil_wstrb = m_axil_wstrb[grant_cdr];
        s_axil_wvalid = m_axil_wvalid[grant_cdr];
        m_axil_wready[grant_cdr] = s_axil_wready;

        m_axil_bresp[grant_cdr] = s_axil_bresp;
        m_axil_bvalid[grant_cdr] = s_axil_bvalid;
        s_axil_bready = m_axil_bready[grant_cdr];
    end
    
endmodule