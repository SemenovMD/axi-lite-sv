module axil_mux_rd
#(
    parameter   AXI_DATA_WIDTH  =   32,
    parameter   AXI_ADDR_WIDTH  =   32
)

(
    input   logic                               slv_invalid,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel READ Master
    ////////////////////////////////////////////////////////////////////////////////////////////////

    // Channel Read Address
    input   logic   [AXI_ADDR_WIDTH-1:0]        m_axil_araddr_0,
    input   logic                               m_axil_arvalid_0,
    output  logic                               m_axil_arready_0,

    // Channel Read Data
    output  logic   [AXI_DATA_WIDTH-1:0]        m_axil_rdata_0,
    output  logic   [1:0]                       m_axil_rresp_0,
    output  logic                               m_axil_rvalid_0,
    input   logic                               m_axil_rready_0,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel READ Master
    ////////////////////////////////////////////////////////////////////////////////////////////////

    // Channel Read Address
    output  logic   [AXI_ADDR_WIDTH-1:0]        m_axil_araddr_1,
    output  logic                               m_axil_arvalid_1,
    input   logic                               m_axil_arready_1,

    // Channel Read Data
    input   logic   [AXI_DATA_WIDTH-1:0]        m_axil_rdata_1,
    input   logic   [1:0]                       m_axil_rresp_1,
    input   logic                               m_axil_rvalid_1,
    output  logic                               m_axil_rready_1,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel READ Master
    ////////////////////////////////////////////////////////////////////////////////////////////////

    // Channel Read Address
    output  logic   [AXI_ADDR_WIDTH-1:0]        m_axil_araddr_2,
    output  logic                               m_axil_arvalid_2,
    input   logic                               m_axil_arready_2,

    // Channel Read Data
    input   logic   [AXI_DATA_WIDTH-1:0]        m_axil_rdata_2,
    input   logic   [1:0]                       m_axil_rresp_2,
    input   logic                               m_axil_rvalid_2,
    output  logic                               m_axil_rready_2
);

    always_comb
    begin
        if (!slv_invalid)
        begin
            m_axil_arready_0        =   m_axil_arready_1;
            m_axil_rdata_0          =   m_axil_rdata_1;
            m_axil_rresp_0          =   m_axil_rresp_1;
            m_axil_rvalid_0         =   m_axil_rvalid_1;

            m_axil_araddr_1         =   m_axil_araddr_0;
            m_axil_arvalid_1        =   m_axil_arvalid_0;
            m_axil_rready_1         =   m_axil_rready_0;

            m_axil_araddr_2         =   '0;
            m_axil_arvalid_2        =   0;
            m_axil_rready_2         =   0;
        end else
        begin
            m_axil_arready_0        =   m_axil_arready_2;
            m_axil_rdata_0          =   m_axil_rdata_2;
            m_axil_rresp_0          =   m_axil_rresp_2;
            m_axil_rvalid_0         =   m_axil_rvalid_2;

            m_axil_araddr_1         =   '0;
            m_axil_arvalid_1        =   0;
            m_axil_rready_1         =   0;

            m_axil_araddr_2         =   m_axil_araddr_0;
            m_axil_arvalid_2        =   m_axil_arvalid_0;
            m_axil_rready_2         =   m_axil_rready_0;
        end
    end

endmodule