/*
 * Module: axis_converter_lite
 * 
 * Description:
 *   This module converts AXI-Stream data to AXI-Lite interface and vice versa. 
 *   It handles both read and write transactions for the AXI-Lite interface, while 
 *   managing data transfer and control signals for the AXI-Stream interface. The 
 *   module ensures data integrity and proper handshaking between AXI-Stream and 
 *   AXI-Lite protocols.
 * 
 * Features:
 *   - Manages AXI-Lite read and write transactions
 *   - Interfaces with AXI-Stream for data transfer
 *   - Implements finite state machines (FSM) for AXI-Lite read and write operations
 * 
 * Parameters:
 *   - AXI_DATA_WIDTH : Width of the input data bus (default: 32 bits)
 *   - AXI_ADDR_WIDTH : Width of the address bus (default: 32 bits)
 *   - AXI_ADDR       : Address for AXI-Lite transactions (default: 32'h0000_0001)
 * 
 * Ports:
 *   - aclk     : Input     : Clock signal
 *   - aresetn  : Input     : Synchronous active-low reset
 *   - m_axis   : Interface : Master AXI-Stream interface
 *   - s_axis   : Interface : Slave AXI-Stream interface
 *   - s_axil   : Interface : Slave AXI-Lite interface
 * 
 * Notes:
 *   - Ensure that the module is properly reset before use.
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
 * Date  : 09.06.2024
 *
 */

`timescale 1ns / 1ps

module axis_converter_lite

    import axis_converter_lite_pkg_prm::*;

(
    // Global signals
    input   logic                               aclk,
    input   logic                               aresetn,

    // Interface AXI-Stream
    axis_if.m_axis                              m_axis,
    axis_if.s_axis                              s_axis,

    // Interface AXI-Lite Slave
    axil_if.s_axil                              s_axil   
);

    logic   [AXI_DATA_WIDTH-1:0]        m_axis_tdata_buf;
    logic                               m_axis_flag;
    logic   [AXI_DATA_WIDTH-1:0]        s_axis_tdata_buf;

    // FSM AXI-Lite Slave WRITE
    typedef enum logic [1:0]
    {  
        WRITE_IDLE,
        WRITE_PAUSE,
        WRITE_TRAN_1,
        WRITE_TRAN_2
    } state_type_wr;

    state_type_wr state_wr;

    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_wr <= WRITE_IDLE;
            s_axil.awready <= 1'b0;
            s_axil.wready <= 1'b0;
            s_axil.bvalid <= 1'b0;
            s_axil.bresp <= 2'b00;
            m_axis.tdata <= '0;
            m_axis.tvalid <= 1'b0;
        end else
        begin
            case (state_wr)
                WRITE_IDLE:
                    begin
                        if (!(&{s_axil.awvalid, s_axil.wvalid}))
                        begin
                            state_wr <= WRITE_IDLE;
                        end else 
                        begin
                            state_wr <= WRITE_PAUSE;
                            s_axil.awready <= 1'b1;
                            s_axil.wready <= 1'b1;

                            if (s_axil.awaddr == AXI_ADDR)
                            begin
                                m_axis_tdata_buf <= s_axil.wdata;
                                s_axil.bresp <= 2'b00;
                            end else
                            begin
                                s_axil.bresp <= 2'b11;
                            end
                        end
                    end
                WRITE_PAUSE:
                    begin
                        state_wr <= WRITE_TRAN_1;
                        s_axil.awready <= 1'b0;
                        s_axil.wready <= 1'b0;
                        s_axil.bvalid <= 1'b1;
                    end
                WRITE_TRAN_1:
                    begin
                        if (!s_axil.bready)
                        begin
                            state_wr <= WRITE_TRAN_1;
                        end else
                        begin
                            s_axil.bvalid <= 1'b0;
                            s_axil.bresp <= 2'b00;

                            if (&s_axil.bresp)
                            begin
                                state_wr <= WRITE_IDLE;
                            end else
                            begin
                                state_wr <= WRITE_TRAN_2;
                                m_axis.tdata <= m_axis_tdata_buf;
                                m_axis.tvalid <= 1'b1;                             
                            end
                        end
                    end
                WRITE_TRAN_2:
                    begin
                        if (!m_axis.tready)
                        begin
                            state_wr <= WRITE_TRAN_2;
                        end else
                        begin
                            state_wr <= WRITE_IDLE;
                            m_axis.tdata <= '0;
                            m_axis.tvalid <= 1'b0;
                        end
                    end
            endcase
        end
    end

    // FSM AXI-Lite Slave READ
    typedef enum logic [1:0]
    {  
        READ_IDLE,
        READ_PAUSE,
        READ_RESP
    } state_type_rd;

    state_type_rd state_rd;

    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_rd <= READ_IDLE;
            s_axil.arready <= 1'b0;
            s_axil.rdata <= '0;
            s_axil.rresp <= 2'b00;
            s_axil.rvalid <= 1'b0;
            s_axis.tready <= 1'b0;           
        end else
        begin
            case (state_rd)
                READ_IDLE:
                    begin
                        if (!s_axil.arvalid)
                        begin
                            state_rd <= READ_IDLE;
                        end else 
                        begin
                            if (s_axil.araddr == AXI_ADDR)
                            begin
                                if (!s_axis.tvalid)
                                begin
                                    state_rd <= READ_IDLE;
                                end else
                                begin
                                    state_rd <= READ_PAUSE;
                                    s_axil.arready <= 1'b1;
                                    s_axil.rresp <= 2'b00;
                                    s_axis_tdata_buf <= s_axis.tdata;
                                    s_axis.tready <= 1'b1;
                                end
                            end else
                            begin
                                state_rd <= READ_PAUSE;
                                s_axil.arready <= 1'b1;
                                s_axil.rresp <= 2'b11;
                            end
                        end
                    end
                READ_PAUSE:
                    begin
                        state_rd <= READ_RESP;
                        s_axil.arready <= 1'b0;
                        s_axil.rvalid <= 1'b1;
                        s_axis.tready <= 1'b0;

                        if (&s_axil.rresp)
                        begin
                            s_axil.rdata <= '0;
                        end else
                        begin
                            s_axil.rdata <= s_axis_tdata_buf;
                        end
                    end
                READ_RESP:
                    begin
                        if (!s_axil.rready)
                        begin
                            state_rd <= READ_RESP;
                        end else
                        begin
                            state_rd <= READ_IDLE;
                            s_axil.rdata <= '0;
                            s_axil.rvalid <= 1'b0;
                            s_axil.rresp <= 2'b00;
                        end
                    end
            endcase
        end
    end

endmodule