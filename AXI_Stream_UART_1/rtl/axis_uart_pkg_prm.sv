package axis_uart_pkg_prm;

    parameter AXI_DATA_WIDTH    = 8;

    parameter CLOCK             = 100_000_000;

    parameter BAUD_RATE         = 115_200;
    parameter DATA_BITS         = 8;
    parameter STOP_BITS         = 1;
    parameter PARITY_BITS       = 0; // 1 means even parity, 0 means odd parity

endpackage