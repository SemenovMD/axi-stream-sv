package axis_crc32_mpeg2_pkg_tb;

    import axis_crc32_mpeg2_pkg_prm::AXI_DATA_WIDTH;

    parameter AXI_TRAN_MIN_DELAY = 1;
    parameter AXI_TRAN_MAX_DELAY = 17;

    parameter AXI_TRAN_MAX_WAIT = 50;

    class crc32_mpeg2;

        // Calculate the CRC32 MPEG2
        task automatic crc_calc
        
        (
            input   logic   [AXI_DATA_WIDTH-1:0]        s_axis_tdata,

            input   logic   [31:0]                      init_crc,
            input   logic   [31:0]                      poly_crc,

            output  logic   [31:0]                      crc
        );

            begin
                crc = init_crc ^ s_axis_tdata;

                for (int i = 0; i < AXI_DATA_WIDTH; i = i + 1) 
                begin
                    if (crc[31]) 
                    begin
                        crc = (crc << 1) ^ poly_crc;
                    end else 
                    begin
                        crc = crc << 1;
                    end
                end
            end

        endtask

        // Comparate the CRC32 MPEG2 expected and calculated
        task automatic crc_comp
        
        (
            input   logic   [31:0]                      data_expected,
            input   logic   [31:0]                      data_calculate
        );

            begin
                if (data_expected != data_calculate)
                begin 
                    $display("Test failed: CRC mismatch. Expected CRC: %h, Calculated CRC: %h", data_expected, data_calculate);
                    $finish;
                end
                else
                begin
                    $display("Test passed: CRC match. Expected CRC: %h, Calculated CRC: %h", data_expected, data_calculate);
                end
            end

        endtask

    endclass

endpackage
