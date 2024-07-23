module axil_crossbar_rd
#(
    parameter   NUMBER_MASTER   = 2,
    parameter   AXI_DATA_WIDTH  = 32,
    parameter   AXI_ADDR_WIDTH  = 32      
)

(
    input   logic   [NUMBER_MASTER-1:0]         grant_rd,

    // Channel Read Address Master
    input   logic   [AXI_ADDR_WIDTH-1:0]        m_axil_araddr   [NUMBER_MASTER],
    input   logic   [NUMBER_MASTER-1:0]         m_axil_arvalid,
    output  logic   [NUMBER_MASTER-1:0]         m_axil_arready,

    // Channel Read Data Master
    output  logic   [AXI_ADDR_WIDTH-1:0]        m_axil_rdata    [NUMBER_MASTER],
    output  logic   [1:0]                       m_axil_rresp    [NUMBER_MASTER],
    output  logic   [NUMBER_MASTER-1:0]         m_axil_rvalid,
    input   logic   [NUMBER_MASTER-1:0]         m_axil_rready,

    // Channel Read Address Slave
    output  logic   [AXI_ADDR_WIDTH-1:0]        s_axil_araddr,
    output  logic                               s_axil_arvalid,
    input   logic                               s_axil_arready,

    // Channel Read Data Slave
    input   logic   [AXI_ADDR_WIDTH-1:0]        s_axil_rdata,
    input   logic   [1:0]                       s_axil_rresp,
    input   logic                               s_axil_rvalid,
    output  logic                               s_axil_rready
);

    logic   [$clog2(NUMBER_MASTER)-1:0] grant_cdr;

    always_comb 
    begin
        grant_cdr = '0;

        for (int i = 0; i < NUMBER_MASTER; i++) 
        begin
            if (grant_rd[i]) 
            begin
                grant_cdr = i;
                break;
            end
        end
    end

    always_comb
    begin
        s_axil_araddr           = '0;
        s_axil_arvalid          = 0;

        s_axil_rready           = 0;

        for (int i = 0; i < NUMBER_MASTER; i++) 
        begin
            m_axil_arready[i]   = 0;
            m_axil_rdata[i]     = '0;
            m_axil_rresp[i]     = '0;
            m_axil_rvalid[i]    = 0;
        end 

        s_axil_araddr = m_axil_araddr[grant_cdr];
        s_axil_arvalid = m_axil_arvalid[grant_cdr];
        m_axil_arready[grant_cdr] = s_axil_arready;

        m_axil_rdata[grant_cdr] = s_axil_rdata;
        m_axil_rresp[grant_cdr] = s_axil_rresp;
        m_axil_rvalid[grant_cdr] = s_axil_rvalid;        
        s_axil_rready = m_axil_rready[grant_cdr];
    end
    
endmodule