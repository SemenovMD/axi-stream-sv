module axis_fifo_wrapper_sv

#(parameter AXI_DATA_WIDTH = 32,
            AXI_DATA_DEPTH = 32)

(
    // Global signals
    input  logic                            aclk,
    input  logic                            aresetn,

    // Flag State
    output  logic                           fifo_empty,
    output  logic                           fifo_half,
    output  logic                           fifo_full,

    // Interface Slave
    input  logic   [AXI_DATA_WIDTH-1:0]     s_axis_tdata,
    input  logic                            s_axis_tvalid,
    output logic                            s_axis_tready,

    // Interface Master
    output logic   [AXI_DATA_WIDTH-1:0]     m_axis_tdata,
    output logic                            m_axis_tvalid,
    input  logic                            m_axis_tready
);

    axis_if #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH)) m_axis();
    axis_if #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH)) s_axis();

    generate
        assign m_axis_tdata  = m_axis.tdata;
        assign m_axis_tvalid = m_axis.tvalid;
        assign m_axis.tready = m_axis_tready;

        assign s_axis.tdata  = s_axis_tdata;
        assign s_axis.tvalid = s_axis_tvalid;
        assign s_axis_tready = s_axis.tready;
    endgenerate
    
    axis_fifo #
    (
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_DATA_DEPTH(AXI_DATA_DEPTH)
    ) 
    
    axis_fifo_inst
    
    (
        .*
    );

endmodule