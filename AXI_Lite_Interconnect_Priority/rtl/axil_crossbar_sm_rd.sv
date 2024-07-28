module axil_crossbar_sm_rd
#(
    parameter   NUMBER_SLAVE    = 8,
    parameter   AXI_DATA_WIDTH  = 32,
    parameter   AXI_ADDR_WIDTH  = 32
)

(
    input   logic   [NUMBER_SLAVE-1:0]              grant_rd_trans,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel READ Master
    ////////////////////////////////////////////////////////////////////////////////////////////////    

    // Channel Read Address
    output  logic                                   m_axil_arready,

    // Channel Read Data
    output  logic   [AXI_DATA_WIDTH-1:0]            m_axil_rdata,
    output  logic   [1:0]                           m_axil_rresp,
    output  logic                                   m_axil_rvalid,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel READ Slave
    ////////////////////////////////////////////////////////////////////////////////////////////////

    // Channel Read Address
    input   logic   [NUMBER_SLAVE-1:0]              s_axil_arready,

    // Channel Read Data
    input   logic   [AXI_DATA_WIDTH-1:0]            s_axil_rdata            [NUMBER_SLAVE],
    input   logic   [1:0]                           s_axil_rresp            [NUMBER_SLAVE],
    input   logic   [NUMBER_SLAVE-1:0]              s_axil_rvalid
);

    always_comb
    begin
        m_axil_arready  = 0;
        m_axil_rdata    = '0;
        m_axil_rresp    = '0;
        m_axil_rvalid   = 0;

        for (int j = 0; j < NUMBER_SLAVE; j++) 
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