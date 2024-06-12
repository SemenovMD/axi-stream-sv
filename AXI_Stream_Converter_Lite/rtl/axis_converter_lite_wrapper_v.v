module axis_converter_lite_wrapper_v

#(parameter AXI_DATA_WIDTH = 32,
            AXI_ADDR_WIDTH = 32,
            AXI_ADDR       = 32'h0000_0001)

(
    // Global signals
    input  wire                            aclk,
    input  wire                            aresetn,

    // Interface AXI-Stream Slave
    input  wire   [AXI_DATA_WIDTH-1:0]     s_axis_tdata,
    input  wire                            s_axis_tvalid,
    output wire                            s_axis_tready,

    // Interface AXI-Stream Master
    output wire   [AXI_DATA_WIDTH-1:0]     m_axis_tdata,
    output wire                            m_axis_tvalid,
    input  wire                            m_axis_tready,

    // Interface AXI-Lite Slave
    input  wire   [AXI_ADDR_WIDTH-1:0]     s_axil_awaddr,
    input  wire                            s_axil_awvalid,
    output wire                            s_axil_awready,

    input  wire   [AXI_DATA_WIDTH-1:0]     s_axil_wdata,
    input  wire   [AXI_DATA_WIDTH/8-1:0]   s_axil_wstrb,
    input  wire                            s_axil_wvalid,
    output wire                            s_axil_wready,
                               
    output wire   [1:0]                    s_axil_bresp,
    output wire                            s_axil_bvalid,
    input  wire                            s_axil_bready,

    input  wire   [AXI_ADDR_WIDTH-1:0]     s_axil_araddr,
    input  wire                            s_axil_arvalid,
    output wire                            s_axil_arready,

    output wire   [AXI_DATA_WIDTH-1:0]     s_axil_rdata,
    output wire   [1:0]                    s_axil_rresp,
    output wire                            s_axil_rvalid,
    input  wire                            s_axil_rready
);

    axis_converter_lite_wrapper_sv #(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_ADDR(AXI_ADDR)
    ) 

    axis_converter_lite_wrapper_sv_inst
    
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
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