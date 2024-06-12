module axis_crc32_mpeg2_wrapper_sv

#(parameter AXI_DATA_WIDTH = 32,
            POLY_CRC       = 32'h04C1_1DB7,
            INIT_CRC       = 32'hFFFF_FFFF)

(
    // Global signals
    input  logic                            aclk,
    input  logic                            aresetn,

    // Flag State
    output logic                            crc_done,

    // Interface Slave
    input  logic   [AXI_DATA_WIDTH-1:0]     s_axis_tdata,
    input  logic                            s_axis_tvalid,
    output logic                            s_axis_tready,

    // Interface Master
    output logic   [AXI_DATA_WIDTH-1:0]     m_axis_tdata,
    output logic                            m_axis_tvalid,
    input  logic                            m_axis_tready
);

    axis_if m_axis();
    axis_if s_axis();

    generate
        assign m_axis_tdata  = m_axis.tdata;
        assign m_axis_tvalid = m_axis.tvalid;
        assign m_axis.tready = m_axis_tready;

        assign s_axis.tdata  = s_axis_tdata;
        assign s_axis.tvalid = s_axis_tvalid;
        assign s_axis_tready = s_axis.tready;
    endgenerate
    
    axis_crc32_mpeg2 #
    (
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .POLY_CRC(POLY_CRC),
        .INIT_CRC(INIT_CRC)
    ) 
    
    axis_crc32_mpeg2_inst
    
    (
        .*
    );

endmodule