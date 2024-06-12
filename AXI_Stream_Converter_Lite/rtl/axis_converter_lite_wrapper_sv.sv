module axis_converter_lite_wrapper_sv

#(parameter AXI_DATA_WIDTH = 32,
            AXI_ADDR_WIDTH = 32,
            AXI_ADDR       = 32'h0000_0001)

(
    // Global signals
    input  logic                            aclk,
    input  logic                            aresetn,

    // Interface AXI-Stream Slave
    input  logic   [AXI_DATA_WIDTH-1:0]     s_axis_tdata,
    input  logic                            s_axis_tvalid,
    output logic                            s_axis_tready,

    // Interface AXI-Stream Master
    output logic   [AXI_DATA_WIDTH-1:0]     m_axis_tdata,
    output logic                            m_axis_tvalid,
    input  logic                            m_axis_tready,

    // Interface AXI-Lite Slave
    input  logic   [AXI_ADDR_WIDTH-1:0]     s_axil_awaddr,
    input  logic                            s_axil_awvalid,
    output logic                            s_axil_awready,

    input  logic   [AXI_DATA_WIDTH-1:0]     s_axil_wdata,
    input  logic   [AXI_DATA_WIDTH/8-1:0]   s_axil_wstrb,
    input  logic                            s_axil_wvalid,
    output logic                            s_axil_wready,
                               
    output logic   [1:0]                    s_axil_bresp,
    output logic                            s_axil_bvalid,
    input  logic                            s_axil_bready,

    input  logic   [AXI_ADDR_WIDTH-1:0]     s_axil_araddr,
    input  logic                            s_axil_arvalid,
    output logic                            s_axil_arready,

    output logic   [AXI_DATA_WIDTH-1:0]     s_axil_rdata,
    output logic   [1:0]                    s_axil_rresp,
    output logic                            s_axil_rvalid,
    input  logic                            s_axil_rready
);

    axis_if #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH)) m_axis();
    axis_if #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH)) s_axis();

    axil_if #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH), .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)) s_axil();

    generate
        assign m_axis_tdata   = m_axis.tdata;
        assign m_axis_tvalid  = m_axis.tvalid;
        assign m_axis.tready  = m_axis_tready;

        assign s_axis.tdata   = s_axis_tdata;
        assign s_axis.tvalid  = s_axis_tvalid;
        assign s_axis_tready  = s_axis.tready;

        assign s_axil.awaddr  = s_axil_awaddr;
        assign s_axil.awvalid = s_axil_awvalid;
        assign s_axil_awready = s_axil.awready;

        assign s_axil.wdata   = s_axil_wdata;
        assign s_axil.wstrb   = s_axil_wstrb;
        assign s_axil.wvalid  = s_axil_wvalid;
        assign s_axil_wready  = s_axil.wready;

        assign s_axil_bresp   = s_axil.bresp;
        assign s_axil_bvalid  = s_axil.bvalid;
        assign s_axil.bready  = s_axil_bready;

        assign s_axil.araddr  = s_axil_araddr;
        assign s_axil.arvalid = s_axil_arvalid;
        assign s_axil_arready = s_axil.arready;

        assign s_axil_rdata   = s_axil.rdata;
        assign s_axil_rresp   = s_axil.rresp;
        assign s_axil_rvalid  = s_axil.rvalid;
        assign s_axil.rready  = s_axil_rready;
    endgenerate
    
    axis_converter_lite #
    (
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_ADDR(AXI_ADDR)
    ) 
    
    axis_converter_lite_inst
    
    (
        .*
    );

endmodule