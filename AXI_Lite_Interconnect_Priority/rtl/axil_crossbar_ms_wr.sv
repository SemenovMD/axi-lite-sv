module axil_crossbar_ms_wr
    
    import axil_pkg ::*;

(
    input   logic   [NUMBER_MASTER-1:0]            grant_wr,

    // Channel Write Master Address
    input   logic   [AXI_ADDR_WIDTH-1:0]           m_axil_awaddr       [NUMBER_MASTER],
    input   logic   [NUMBER_MASTER-1:0]            m_axil_awvalid,

    // Channel Write Master Data
    input   logic   [AXI_DATA_WIDTH-1:0]           m_axil_wdata        [NUMBER_MASTER],
    input   logic   [AXI_DATA_WIDTH/8-1:0]         m_axil_wstrb        [NUMBER_MASTER],
    input   logic   [NUMBER_MASTER-1:0]            m_axil_wvalid,

    // Channel Write Master Response
    input   logic   [NUMBER_MASTER-1:0]            m_axil_bready,

    // Channel Write Slave Address
    output  logic   [AXI_ADDR_WIDTH-1:0]           s_axil_awaddr,
    output  logic                                  s_axil_awvalid,

    // Channel Write Slave Data
    output  logic   [AXI_DATA_WIDTH-1:0]           s_axil_wdata,
    output  logic   [AXI_DATA_WIDTH/8-1:0]         s_axil_wstrb,
    output  logic                                  s_axil_wvalid,

    // Channel Write Slave Response
    output  logic                                  s_axil_bready
);

    always_comb
    begin
        s_axil_awaddr  = '0;
        s_axil_awvalid = 0;
        s_axil_wdata   = '0;
        s_axil_wstrb   = '0;
        s_axil_wvalid  = 0;
        s_axil_bready  = 0;

        for (int j = 0; j < NUMBER_MASTER; j++) begin
            if (grant_wr[j]) 
            begin
                s_axil_awaddr  = m_axil_awaddr[j];
                s_axil_awvalid = m_axil_awvalid[j];
                s_axil_wdata   = m_axil_wdata[j];
                s_axil_wstrb   = m_axil_wstrb[j];
                s_axil_wvalid  = m_axil_wvalid[j];
                s_axil_bready  = m_axil_bready[j];
            end
        end
    end

endmodule