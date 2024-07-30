module axil_crossbar_sm_rd

    import axil_pkg ::*;

(
    input   logic   [NUMBER_SLAVE:0]                grant_rd_trans,  

    // Channel Read Master Address
    output  logic                                   m_axil_arready,

    // Channel Read Master Data
    output  logic   [AXI_DATA_WIDTH-1:0]            m_axil_rdata,
    output  logic   [1:0]                           m_axil_rresp,
    output  logic                                   m_axil_rvalid,

    // Channel Read Slave Address
    input   logic   [NUMBER_SLAVE:0]                s_axil_arready,

    // Channel Read Slave Data
    input   logic   [AXI_DATA_WIDTH-1:0]            s_axil_rdata            [NUMBER_SLAVE+1],
    input   logic   [1:0]                           s_axil_rresp            [NUMBER_SLAVE+1],
    input   logic   [NUMBER_SLAVE:0]                s_axil_rvalid
);

    always_comb
    begin
        m_axil_arready  = 0;
        m_axil_rdata    = '0;
        m_axil_rresp    = '0;
        m_axil_rvalid   = 0;

        for (int j = 0; j < NUMBER_SLAVE+1; j++) 
        begin
            if (grant_rd_trans[j])
            begin
                m_axil_arready = s_axil_arready[j];
                m_axil_rdata   = s_axil_rdata[j];
                m_axil_rresp   = s_axil_rresp[j];
                m_axil_rvalid  = s_axil_rvalid[j];
            end
        end
    end

endmodule