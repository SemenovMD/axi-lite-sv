module axil_mux_wr
#(
    parameter   AXI_DATA_WIDTH  =   32,
    parameter   AXI_ADDR_WIDTH  =   32
)

(
    input   logic                               slv_invalid,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel WRITE Master
    ////////////////////////////////////////////////////////////////////////////////////////////////

    // Channel Write Address
    input   logic   [AXI_ADDR_WIDTH-1:0]        m_axil_awaddr_0,
    input   logic                               m_axil_awvalid_0,
    output  logic                               m_axil_awready_0,

    // Channel Write Data
    input   logic   [AXI_ADDR_WIDTH-1:0]        m_axil_wdata_0,
    input   logic   [AXI_DATA_WIDTH/8-1:0]      m_axil_wstrb_0,
    input   logic                               m_axil_wvalid_0,
    output  logic                               m_axil_wready_0,

    // Channel Write Response
    output  logic   [1:0]                       m_axil_bresp_0,
    output  logic                               m_axil_bvalid_0,
    input   logic                               m_axil_bready_0,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel WRITE Master
    ////////////////////////////////////////////////////////////////////////////////////////////////

    // Channel Write Address
    output  logic   [AXI_ADDR_WIDTH-1:0]        m_axil_awaddr_1,
    output  logic                               m_axil_awvalid_1,
    input   logic                               m_axil_awready_1,

    // Channel Write Data
    output  logic   [AXI_ADDR_WIDTH-1:0]        m_axil_wdata_1,
    output  logic   [AXI_DATA_WIDTH/8-1:0]      m_axil_wstrb_1,
    output  logic                               m_axil_wvalid_1,
    input   logic                               m_axil_wready_1,

    // Channel Write Response
    input   logic   [1:0]                       m_axil_bresp_1,
    input   logic                               m_axil_bvalid_1,
    output  logic                               m_axil_bready_1,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Channel WRITE Master
    ////////////////////////////////////////////////////////////////////////////////////////////////

    // Channel Write Address
    output  logic   [AXI_ADDR_WIDTH-1:0]        m_axil_awaddr_2,
    output  logic                               m_axil_awvalid_2,
    input   logic                               m_axil_awready_2,

    // Channel Write Data
    output  logic   [AXI_ADDR_WIDTH-1:0]        m_axil_wdata_2,
    output  logic   [AXI_DATA_WIDTH/8-1:0]      m_axil_wstrb_2,
    output  logic                               m_axil_wvalid_2,
    input   logic                               m_axil_wready_2,

    // Channel Write Response
    input   logic   [1:0]                       m_axil_bresp_2,
    input   logic                               m_axil_bvalid_2,
    output  logic                               m_axil_bready_2
);

    always_comb
    begin
        if (!slv_invalid)
        begin
            m_axil_awready_0        =   m_axil_awready_1;
            m_axil_wready_0         =   m_axil_wready_1;
            m_axil_bresp_0          =   m_axil_bresp_1;
            m_axil_bvalid_0         =   m_axil_bvalid_1;

            m_axil_awaddr_1         =   m_axil_awaddr_0;
            m_axil_awvalid_1        =   m_axil_awvalid_0;
            m_axil_wdata_1          =   m_axil_wdata_0;
            m_axil_wstrb_1          =   m_axil_wstrb_0;
            m_axil_wvalid_1         =   m_axil_wvalid_0;
            m_axil_bready_1         =   m_axil_bready_0;

            m_axil_awaddr_2         =   '0;
            m_axil_awvalid_2        =   0;
            m_axil_wdata_2          =   '0;
            m_axil_wstrb_2          =   '0;
            m_axil_wvalid_2         =   0;
            m_axil_bready_2         =   0;
        end else
        begin
            m_axil_awready_0        =   m_axil_awready_2;
            m_axil_wready_0         =   m_axil_wready_2;
            m_axil_bresp_0          =   m_axil_bresp_2;
            m_axil_bvalid_0         =   m_axil_bvalid_2;

            m_axil_awaddr_1         =   '0;
            m_axil_awvalid_1        =   0;
            m_axil_wdata_1          =   '0;
            m_axil_wstrb_1          =   '0;
            m_axil_wvalid_1         =   0;
            m_axil_bready_1         =   0;

            m_axil_awaddr_2         =   m_axil_awaddr_0;
            m_axil_awvalid_2        =   m_axil_awvalid_0;
            m_axil_wdata_2          =   m_axil_wdata_0;
            m_axil_wstrb_2          =   m_axil_wstrb_0;
            m_axil_wvalid_2         =   m_axil_wvalid_0;
            m_axil_bready_2         =   m_axil_bready_0;
        end
    end

endmodule