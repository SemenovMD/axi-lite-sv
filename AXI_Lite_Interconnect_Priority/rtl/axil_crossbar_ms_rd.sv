module axil_crossbar_ms_rd

    import axil_pkg ::*;

(
    input   logic   [NUMBER_MASTER-1:0]             grant_rd,

    // Channel Read Master Address
    input   logic   [AXI_ADDR_WIDTH-1:0]            m_axil_araddr       [NUMBER_MASTER],
    input   logic   [NUMBER_MASTER-1:0]             m_axil_arvalid,

    // Channel Read Master Data
    input   logic   [NUMBER_MASTER-1:0]             m_axil_rready,

    // Channel Read Slave Address
    output  logic   [AXI_ADDR_WIDTH-1:0]            s_axil_araddr,
    output  logic                                   s_axil_arvalid,

    // Channel Read Slave Data
    output  logic                                   s_axil_rready
);

    always_comb
    begin
        s_axil_araddr  = '0;
        s_axil_arvalid = 0;
        s_axil_rready  = 0;

        for (int j = 0; j < NUMBER_MASTER; j++) begin
            if (grant_rd[j]) 
            begin
                s_axil_araddr   = m_axil_araddr[j];
                s_axil_arvalid  = m_axil_arvalid[j];
                s_axil_rready   = m_axil_rready[j];
            end
        end
    end

endmodule