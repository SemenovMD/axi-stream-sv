module axis_fifo_wrapper_v

#(parameter AXI_DATA_WIDTH = 32,
            AXI_DATA_DEPTH = 32)

(
    // Global signals
    input  wire                            aclk,
    input  wire                            aresetn,

    // Flag State
    output wire                            fifo_empty,
    output wire                            fifo_half,
    output wire                            fifo_full,

    // Interface Slave
    input  wire   [AXI_DATA_WIDTH-1:0]     s_axis_tdata,
    input  wire                            s_axis_tvalid,
    output wire                            s_axis_tready,

    // Interface Master
    output wire   [AXI_DATA_WIDTH-1:0]     m_axis_tdata,
    output wire                            m_axis_tvalid,
    input  wire                            m_axis_tready
);

    axis_fifo_wrapper_sv #(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_DATA_DEPTH(AXI_DATA_DEPTH)
    ) 

    axis_fifo_wrapper_sv_inst
    
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .fifo_empty(fifo_empty),
        .fifo_half(fifo_half),
        .fifo_full(fifo_full),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready)
    );

endmodule