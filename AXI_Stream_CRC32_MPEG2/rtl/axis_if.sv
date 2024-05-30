interface axis_if;

    import axis_crc32_mpeg2_pkg_prm::AXI_DATA_WIDTH;

    logic   [AXI_DATA_WIDTH-1:0]    tdata;
    logic                           tvalid;
    logic                           tready;

    modport m_axis
    (
        output tdata,
        output tvalid,
        input  tready
    );

    modport s_axis
    (
        input  tdata,
        input  tvalid,
        output tready
    );

endinterface
