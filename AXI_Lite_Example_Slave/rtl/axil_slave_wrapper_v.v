module axil_slave_wrapper_v 

#(
    parameter   AXI_DATA_WIDTH  =   32,
    parameter   AXI_ADDR_WIDTH  =   32
)

(
    // Global Signals
    input   wire                            aclk,
    input   wire                            aresetn,

    // Interface GPIO
    output  wire    [AXI_DATA_WIDTH-1:0]    gpio_out,


    // Interface AXI-Lite Slave
    input   wire    [AXI_ADDR_WIDTH-1:0]    s_axil_awaddr,
    input   wire                            s_axil_awvalid,
    output  wire                            s_axil_awready,

    input   wire    [AXI_DATA_WIDTH-1:0]    s_axil_wdata,
    input   wire    [AXI_DATA_WIDTH/8-1:0]  s_axil_wstrb,
    input   wire                            s_axil_wvalid,
    output  wire                            s_axil_wready,

    output  wire    [1:0]                   s_axil_bresp,
    output  wire                            s_axil_bvalid,
    input   wire                            s_axil_bready,

    input   wire    [AXI_ADDR_WIDTH-1:0]    s_axil_araddr,
    input   wire                            s_axil_arvalid,
    output  wire                            s_axil_arready,

    output  wire    [AXI_DATA_WIDTH-1:0]    s_axil_rdata,
    output  wire    [1:0]                   s_axil_rresp,
    output  wire                            s_axil_rvalid,
    input   wire                            s_axil_rready
);

    ////////////////////////////////////////////////////////////////////////////////////
    // Instantiate SystemVerilog wrapper
    ////////////////////////////////////////////////////////////////////////////////////

    axil_slave_wrapper_sv #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH), .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)) axil_slave_wrapper_sv_inst
    (
        .aclk(aclk),
        .aresetn(aresetn),
    
        .gpio_out(gpio_out),
        
        .s_axil_awaddr(s_axil_awaddr),
        .s_axil_awvalid(s_axil_awvalid),
        .s_axil_awready(s_axil_awready),
        
        .s_axil_wdata(s_axil_wdata),
        .s_axil_wstrb(s_axil_wstrb),
        .s_axil_wvalid(s_axil_wvalid),
        .s_axil_wready(s_axil_wready),
        
        .s_axil_bresp(s_axil_bresp),
        .s_axil_bvalid(s_axil_bvalid),
        .s_axil_bready(s_axil_bready),
        
        .s_axil_araddr(s_axil_araddr),
        .s_axil_arvalid(s_axil_arvalid),
        .s_axil_arready(s_axil_arready),
        
        .s_axil_rdata(s_axil_rdata),
        .s_axil_rresp(s_axil_rresp),
        .s_axil_rvalid(s_axil_rvalid),
        .s_axil_rready(s_axil_rready)
    );

endmodule