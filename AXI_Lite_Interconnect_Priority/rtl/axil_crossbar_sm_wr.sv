module axil_crossbar_sm_wr

    import axil_pkg ::*;

(
    input   logic   [NUMBER_SLAVE:0]               grant_wr_trans,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel WRITE Master
    ////////////////////////////////////////////////////////////////////////////////////////////////

    // Channel Write Address Master
    output  logic                                  m_axil_awready,

    // Channel Write Data Master
    output  logic                                  m_axil_wready,

    // Channel Write Response Master
    output  logic   [1:0]                          m_axil_bresp,
    output  logic                                  m_axil_bvalid,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel WRITE Slave
    ////////////////////////////////////////////////////////////////////////////////////////////////

    // Channel Write Address Slave
    input   logic   [NUMBER_SLAVE:0]             s_axil_awready,

    // Channel Write Data Slave
    input   logic   [NUMBER_SLAVE:0]             s_axil_wready,

    // Channel Write Response Slave
    input   logic   [1:0]                        s_axil_bresp        [NUMBER_SLAVE+1],
    input   logic   [NUMBER_SLAVE:0]             s_axil_bvalid
);

    always_comb
    begin
        m_axil_awready  = 0;
        m_axil_wready   = 0;
        m_axil_bresp    = '0;
        m_axil_bvalid   = 0;

        for (int j = 0; j < NUMBER_SLAVE+1; j++)
        begin
            if (grant_wr_trans[j])
            begin
                m_axil_awready = s_axil_awready[j];
                m_axil_wready  = s_axil_wready[j];
                m_axil_bresp   = s_axil_bresp[j];
                m_axil_bvalid  = s_axil_bvalid[j];
            end
        end
    end

endmodule