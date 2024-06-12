/*
 * Module: axis_crc32_mpeg2
 * 
 * Description:
 *   This module calculates the CRC-32 checksum according to the MPEG-2 standard
 *   for AXI stream data. The CRC-32 (Cyclic Redundancy Check) is a widely used
 *   error-detecting code, and this implementation is tailored for streaming data
 *   compliant with the AXI (Advanced eXtensible Interface) protocol. It computes
 *   the checksum for each incoming packet of data in the stream, ensuring data 
 *   integrity in high-speed data transfer scenarios.
 * 
 * Features:
 *   - Computes CRC-32 checksum for input AXI stream data
 *   - Supports MPEG-2 CRC-32 polynomial (0x04C11DB7)
 *   - Designed for high-speed data integrity checking in AXI stream applications
 *   - Supports synchronous active-low reset
 *   - Handles data ready/valid flags for AXI stream interfaces
 * 
 * Parameters:
 *   - AXI_DATA_WIDTH : Width of the input data bus (default: 32 bits)
 *   - INIT_CRC       : Initial value for CRC computation (default: 0xFFFFFFFF)
 *   - POLY_CRC       : Polynomial for CRC computation (default: 0x04C11DB7)
 * 
 * Ports:
 *   - aclk      : Input     : Clock signal
 *   - aresetn   : Input     : Synchronous active-low reset
 *   - crc_done  : Output    : Flag indicating the completion of CRC computation
 *   - m_axis    : Interface : Master AXI stream interface
 *   - s_axis    : Interface : Slave AXI stream interface
 * 
 * Notes:
 *   - Ensure that the module is properly reset before use.
 *   - The crc_done signal indicates when the CRC computation is complete.
 * 
 * License:
 *   This is open-source code. The author makes no warranties, expressed or implied,
 *   and assumes no responsibility for any damage or loss resulting from the use of this code.
 *   Use it at your own risk.
 * 
 * Standard:
 *   SystemVerilog IEEE 1800-2012
 * 
 * Author: Semenov Maxim
 * Email : makcsem64@gmail.com
 * Date  : 23.05.2024
 *
 * IMPORTANT: Please make sure that the parameter AXI_DATA_WIDTH = 32, as this module supports only 32-bit input data.
 * For 64-bit words, please use a different crc32_mpeg2 algorithm.
 *
 */

`timescale 1ns / 1ps

module axis_crc32_mpeg2

#(parameter AXI_DATA_WIDTH = 32,
            POLY_CRC       = 32'h04C1_1DB7,
            INIT_CRC       = 32'hFFFF_FFFF)

(
    // Global signals
    input   logic                               aclk,
    input   logic                               aresetn,

    // Flag State
    output  logic                               crc_done,

    // Interface
    axis_if.m_axis                              m_axis,
    axis_if.s_axis                              s_axis
);

    logic   [$clog2(AXI_DATA_WIDTH):0]          crc_count;
    logic   [AXI_DATA_WIDTH-1:0]                crc_buf;

    // FSM CRC32_MPEG2
    typedef enum logic [1:0]
    {  
        CRC_IDLE,
        CRC_CALC_1,
        CRC_CALC_2,
        CRC_WAIT
    } state_type_crc;

    state_type_crc state_crc;

    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_crc <= CRC_IDLE;
            s_axis.tready <= 1'b0;
            m_axis.tvalid <= 1'b0;
            m_axis.tdata <= '0;
            crc_done <= 1'b0;
            crc_count <= '0;
            crc_buf <= '0;
        end else
        begin
            case (state_crc)
                CRC_IDLE:
                    begin
                        if (!s_axis.tvalid)
                        begin
                            state_crc <= CRC_IDLE;
                        end else 
                        begin
                            state_crc <= CRC_CALC_1;
                            crc_buf <= s_axis.tdata;
                            s_axis.tready <= 1;
                        end
                    end
                CRC_CALC_1:
                    begin
                        state_crc <= CRC_CALC_2;
                        crc_buf <= INIT_CRC ^ crc_buf;
                        s_axis.tready <= 1'b0;
                    end
                CRC_CALC_2:
                    begin
                        if (crc_count < AXI_DATA_WIDTH)
                        begin
                            state_crc <= CRC_CALC_2;
                            crc_count <= crc_count + 1;

                            if (crc_buf[AXI_DATA_WIDTH - 1])
                            begin
                                crc_buf <= (crc_buf << 1) ^ POLY_CRC;
                            end else
                            begin
                                crc_buf <= crc_buf << 1;
                            end 
                        end else 
                        begin
                            state_crc <= CRC_WAIT;
                            crc_count <= '0;
                            crc_done <= 1'b1;
                            m_axis.tvalid <= 1'b1;
                            m_axis.tdata <= crc_buf;
                        end                        
                    end
                CRC_WAIT:
                    begin
                        if (!m_axis.tready)
                        begin
                            state_crc <= CRC_WAIT;
                        end else
                        begin
                            state_crc <= CRC_IDLE;
                            m_axis.tvalid <= 1'b0;
                            m_axis.tdata <= '0; 
                        end

                        crc_done <= 1'b0;
                    end
            endcase
        end
    end

endmodule