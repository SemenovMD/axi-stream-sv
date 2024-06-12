module axis_crc32_mpeg2_wrapper_v

#(parameter AXI_DATA_WIDTH = 32,
            POLY_CRC       = 32'h04C1_1DB7,
            INIT_CRC       = 32'hFFFF_FFFF)

(
    // Global signals
    input  wire                            aclk,
    input  wire                            aresetn,

    // Flag State
    output wire                            crc_done,

    // Interface Slave
    input  wire   [AXI_DATA_WIDTH-1:0]     s_axis_tdata,
    input  wire                            s_axis_tvalid,
    output wire                            s_axis_tready,

    // Interface Master
    output wire   [AXI_DATA_WIDTH-1:0]     m_axis_tdata,
    output wire                            m_axis_tvalid,
    input  wire                            m_axis_tready
);

    axis_crc32_mpeg2_wrapper_sv #(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .POLY_CRC(POLY_CRC),
        .INIT_CRC(INIT_CRC)
    ) 

    axis_crc32_mpeg2_wrapper_v_inst
    
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .crc_done(crc_done),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready)
    );

endmodule
