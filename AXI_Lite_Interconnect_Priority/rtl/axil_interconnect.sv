module axil_interconnect

    import axil_pkg ::*;

(
    // Global Signals
    input   logic                               aclk,
    input   logic                               aresetn,

    // Interface
    axil_if.m_axil                              m_axil              [NUMBER_SLAVE],
    axil_if.s_axil                              s_axil              [NUMBER_MASTER]
);

    genvar i;

    // Channel Write Master
    logic   [AXI_ADDR_WIDTH-1:0]        m_axil_awaddr               [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]         m_axil_awvalid;
    logic   [NUMBER_MASTER-1:0]         m_axil_awready;

    logic   [AXI_ADDR_WIDTH-1:0]        m_axil_wdata                [NUMBER_MASTER];
    logic   [AXI_DATA_WIDTH/8-1:0]      m_axil_wstrb                [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]         m_axil_wvalid;
    logic   [NUMBER_MASTER-1:0]         m_axil_wready;

    logic   [1:0]                       m_axil_bresp                [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]         m_axil_bvalid;
    logic   [NUMBER_MASTER-1:0]         m_axil_bready;

    // Channel Write Slave
    logic   [AXI_ADDR_WIDTH-1:0]        s_axil_awaddr               [NUMBER_SLAVE+1];
    logic   [NUMBER_SLAVE:0]            s_axil_awvalid;
    logic   [NUMBER_SLAVE:0]            s_axil_awready;

    logic   [AXI_ADDR_WIDTH-1:0]        s_axil_wdata                [NUMBER_SLAVE+1];
    logic   [AXI_DATA_WIDTH/8-1:0]      s_axil_wstrb                [NUMBER_SLAVE+1];
    logic   [NUMBER_SLAVE:0]            s_axil_wvalid;
    logic   [NUMBER_SLAVE:0]            s_axil_wready;

    logic   [1:0]                       s_axil_bresp                [NUMBER_SLAVE+1];
    logic   [NUMBER_SLAVE:0]            s_axil_bvalid;
    logic   [NUMBER_SLAVE:0]            s_axil_bready;

    // Channel Read Master
    logic   [AXI_ADDR_WIDTH-1:0]        m_axil_araddr               [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]         m_axil_arvalid;
    logic   [NUMBER_MASTER-1:0]         m_axil_arready;

    logic   [AXI_ADDR_WIDTH-1:0]        m_axil_rdata                [NUMBER_MASTER];
    logic   [1:0]                       m_axil_rresp                [NUMBER_MASTER];
    logic   [NUMBER_MASTER-1:0]         m_axil_rvalid;
    logic   [NUMBER_MASTER-1:0]         m_axil_rready;

    // Channel Read Slave
    logic   [AXI_ADDR_WIDTH-1:0]        s_axil_araddr               [NUMBER_SLAVE+1];
    logic   [NUMBER_SLAVE:0]            s_axil_arvalid;
    logic   [NUMBER_SLAVE:0]            s_axil_arready;

    logic   [AXI_ADDR_WIDTH-1:0]        s_axil_rdata                [NUMBER_SLAVE+1];
    logic   [1:0]                       s_axil_rresp                [NUMBER_SLAVE+1];
    logic   [NUMBER_SLAVE:0]            s_axil_rvalid;
    logic   [NUMBER_SLAVE:0]            s_axil_rready;

    ////////////////////////////////////////////////////////////////////////////////////
    // Interconnect WRITE
    ////////////////////////////////////////////////////////////////////////////////////

    axil_interconnect_wr axil_interconnect_wr_inst
    (   
        .aclk(aclk),
        .aresetn(aresetn),
        .m_axil_awaddr(m_axil_awaddr),
        .m_axil_awvalid(m_axil_awvalid),
        .m_axil_awready(m_axil_awready),
        .m_axil_wdata(m_axil_wdata),
        .m_axil_wstrb(m_axil_wstrb),
        .m_axil_wvalid(m_axil_wvalid),
        .m_axil_wready(m_axil_wready),
        .m_axil_bresp(m_axil_bresp),
        .m_axil_bvalid(m_axil_bvalid),
        .m_axil_bready(m_axil_bready),
        .s_axil_awaddr(s_axil_awaddr),
        .s_axil_awvalid(s_axil_awvalid),
        .s_axil_awready(s_axil_awready),
        .s_axil_wdata(s_axil_wdata),
        .s_axil_wstrb(s_axil_wstrb),
        .s_axil_wvalid(s_axil_wvalid),
        .s_axil_wready(s_axil_wready),
        .s_axil_bresp(s_axil_bresp),
        .s_axil_bvalid(s_axil_bvalid),
        .s_axil_bready(s_axil_bready)
    );

    generate
        for (i = 0; i < NUMBER_SLAVE; i++) begin : gen_slave_wr
            assign m_axil[i].awaddr      =   s_axil_awaddr[i];
            assign m_axil[i].awvalid     =   s_axil_awvalid[i];
            assign s_axil_awready[i]     =   m_axil[i].awready;
            
            assign m_axil[i].wdata       =   s_axil_wdata[i];
            assign m_axil[i].wstrb       =   s_axil_wstrb[i];
            assign m_axil[i].wvalid      =   s_axil_wvalid[i];
            assign s_axil_wready[i]      =   m_axil[i].wready;

            assign s_axil_bresp[i]       =   m_axil[i].bresp;
            assign s_axil_bvalid[i]      =   m_axil[i].bvalid;
            assign m_axil[i].bready      =   s_axil_bready[i];
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : gen_master_wr
            assign m_axil_awaddr[i]      =   s_axil[i].awaddr;
            assign m_axil_awvalid[i]     =   s_axil[i].awvalid;
            assign s_axil[i].awready     =   m_axil_awready[i];
            
            assign m_axil_wdata[i]       =   s_axil[i].wdata;
            assign m_axil_wstrb[i]       =   s_axil[i].wstrb;
            assign m_axil_wvalid[i]      =   s_axil[i].wvalid;
            assign s_axil[i].wready      =   m_axil_wready[i];

            assign s_axil[i].bresp       =   m_axil_bresp[i];
            assign s_axil[i].bvalid      =   m_axil_bvalid[i];
            assign m_axil_bready[i]      =   s_axil[i].bready;
        end
    endgenerate

    ////////////////////////////////////////////////////////////////////////////////////
    // SLAVE RESPONSE ADDRESS WRITE INVALID
    ////////////////////////////////////////////////////////////////////////////////////

    axil_response_addr_invalid_wr axil_response_addr_invalid_wr_inst
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axil_awaddr(s_axil_awaddr[NUMBER_SLAVE]),
        .s_axil_awvalid(s_axil_awvalid[NUMBER_SLAVE]),
        .s_axil_wdata(s_axil_wvalid[NUMBER_SLAVE]),
        .s_axil_wstrb(s_axil_wstrb[NUMBER_SLAVE]),
        .s_axil_wvalid(s_axil_wvalid[NUMBER_SLAVE]),
        .s_axil_awready(s_axil_awready[NUMBER_SLAVE]),
        .s_axil_wready(s_axil_wready[NUMBER_SLAVE]),
        .s_axil_bresp(s_axil_bresp[NUMBER_SLAVE]),
        .s_axil_bvalid(s_axil_bvalid[NUMBER_SLAVE]),
        .s_axil_bready(s_axil_bready[NUMBER_SLAVE])
    );

    ////////////////////////////////////////////////////////////////////////////////////
    // Interconnect READ
    ////////////////////////////////////////////////////////////////////////////////////

    axil_interconnect_rd axil_interconnect_rd_inst
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .m_axil_araddr(m_axil_araddr),
        .m_axil_arvalid(m_axil_arvalid),
        .m_axil_arready(m_axil_arready),
        .m_axil_rdata(m_axil_rdata),
        .m_axil_rresp(m_axil_rresp),
        .m_axil_rvalid(m_axil_rvalid),
        .m_axil_rready(m_axil_rready),
        .s_axil_araddr(s_axil_araddr),
        .s_axil_arvalid(s_axil_arvalid),
        .s_axil_arready(s_axil_arready),
        .s_axil_rdata(s_axil_rdata),
        .s_axil_rresp(s_axil_rresp),
        .s_axil_rvalid(s_axil_rvalid),
        .s_axil_rready(s_axil_rready)
    );

    generate
        for (i = 0; i < NUMBER_SLAVE; i++) begin : gen_slave_rd
            assign m_axil[i].araddr         =   s_axil_araddr[i];
            assign m_axil[i].arvalid        =   s_axil_arvalid[i];
            assign s_axil_arready[i]        =   m_axil[i].arready;
            
            assign s_axil_rdata[i]          =   m_axil[i].rdata;
            assign s_axil_rresp[i]          =   m_axil[i].rresp;
            assign s_axil_rvalid[i]         =   m_axil[i].rvalid;
            assign m_axil[i].rready         =   s_axil_rready[i];
        end
    endgenerate

    generate
        for (i = 0; i < NUMBER_MASTER; i++) begin : gen_master_rd
            assign m_axil_araddr[i]         =   s_axil[i].araddr;
            assign m_axil_arvalid[i]        =   s_axil[i].arvalid;
            assign s_axil[i].arready        =   m_axil_arready[i];
            
            assign s_axil[i].rdata          =   m_axil_rdata[i];
            assign s_axil[i].rresp          =   m_axil_rresp[i];
            assign s_axil[i].rvalid         =   m_axil_rvalid[i];
            assign m_axil_rready[i]         =   s_axil[i].rready;
        end
    endgenerate

    ////////////////////////////////////////////////////////////////////////////////////
    // SLAVE RESPONSE ADDRESS READ INVALID
    ////////////////////////////////////////////////////////////////////////////////////

    axil_response_addr_invalid_rd axil_response_addr_invalid_rd_inst
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axil_araddr(s_axil_araddr[NUMBER_SLAVE]),
        .s_axil_arvalid(s_axil_arvalid[NUMBER_SLAVE]),
        .s_axil_arready(s_axil_arready[NUMBER_SLAVE]),
        .s_axil_rdata(s_axil_rdata[NUMBER_SLAVE]),
        .s_axil_rresp(s_axil_rresp[NUMBER_SLAVE]),
        .s_axil_rvalid(s_axil_rvalid[NUMBER_SLAVE]),
        .s_axil_rready(s_axil_rready[NUMBER_SLAVE])
    );

endmodule