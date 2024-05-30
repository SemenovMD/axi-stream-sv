/*
 * Module: axis_fifo
 * 
 * Description:
 *   This module implements a FIFO (First-In-First-Out) buffer for AXI stream data.
 *   It handles data storage and retrieval, managing the data flow between AXI stream 
 *   interfaces. The module supports typical FIFO operations, ensuring data integrity 
 *   and efficient data transfer.
 * 
 * Features:
 *   - Manages FIFO operations for AXI stream data
 *   - Supports synchronous active-low reset
 *   - Handles data ready/valid flags for AXI stream interfaces
 *   - Provides flags for FIFO status (empty, half, full)
 * 
 * Parameters:
 *   - AXI_DATA_WIDTH : Width of the input data bus (default: 32 bits)
 *   - AXI_DATA_DEPTH : Depth of the FIFO (default: 1024)
 * 
 * Ports:
 *   - aclk      : Input     : Clock signal
 *   - aresetn   : Input     : Synchronous active-low reset
 *   - fifo_empty: Output    : Flag indicating the FIFO is empty
 *   - fifo_half : Output    : Flag indicating the FIFO is half
 *   - fifo_full : Output    : Flag indicating the FIFO is full
 *   - m_axis    : Interface : Master AXI stream interface
 *   - s_axis    : Interface : Slave AXI stream interface
 * 
 * Notes:
 *   - Ensure that the module is properly reset before use.
 *   - The fifo_empty, fifo_half, and fifo_full signals indicate the status of the FIFO.
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
 * Date  : 30.05.2024
 *
 */

`timescale 1ns / 1ps

module axis_fifo

    import axis_fifo_pkg_prm::*;

(
    // Global Signals
    input   logic                           aclk,
    input   logic                           aresetn,

    // Flag State
    output  logic                           fifo_empty,
    output  logic                           fifo_half,
    output  logic                           fifo_full,

    // Interface
    axis_if.m_axis                          m_axis,
    axis_if.s_axis                          s_axis
);

    logic [AXI_DATA_WIDTH-1:0] mem [AXI_DATA_DEPTH];

    logic [$clog2(AXI_DATA_DEPTH)-1:0]      index_rd;
    logic [$clog2(AXI_DATA_DEPTH)-1:0]      index_wr;
    logic [$clog2(AXI_DATA_DEPTH)-1:0]      index_rd_wr;

    // FSM_RD State_rd
    typedef enum logic
    {  
        FIFO_IDLE_RD,
        FIFO_HAND_RD        
    } state_type_fifo_rd;

    state_type_fifo_rd state_rd;

    // FSM_RD
    always_ff @(posedge aclk) 
    begin
        if (!aresetn)
        begin
            state_rd <= FIFO_IDLE_RD;
            m_axis.tdata <= '0;
            m_axis.tvalid <= 1'b0;
            index_rd <= '0;
        end else 
        begin
            case (state_rd)
                FIFO_IDLE_RD:
                    begin
                        if (fifo_empty)
                        begin
                            state_rd <= FIFO_IDLE_RD;
                        end else
                        begin
                            state_rd <= FIFO_HAND_RD;
                            m_axis.tdata <= mem[index_rd];
                            m_axis.tvalid <= 1'b1;
                        end
                    end
                FIFO_HAND_RD:
                    begin
                        if (!m_axis.tready)
                        begin
                            state_rd <= FIFO_HAND_RD;
                        end else
                        begin
                            state_rd <= FIFO_IDLE_RD;
                            m_axis.tdata <= '0;
                            m_axis.tvalid <= 1'b0;
                            index_rd <= index_rd + 1;
                        end
                    end
            endcase
        end
    end

    // FSM_WR State_wr
    typedef enum logic
    {  
        FIFO_IDLE_WR,
        FIFO_HAND_WR
    } state_type_fifo_wr;

    state_type_fifo_wr state_wr;

    // FSM_WR
    always_ff @(posedge aclk) 
    begin
        if (!aresetn)
        begin
            state_wr <= FIFO_IDLE_WR;
            s_axis.tready <= 1'b0;
            index_wr <= '0;
        end else 
        begin
            case (state_wr)
                FIFO_IDLE_WR:
                    begin
                        if (fifo_full)
                        begin
                            state_wr <= FIFO_IDLE_WR;
                        end else
                        begin
                            state_wr <= FIFO_HAND_WR;
                            s_axis.tready <= 1'b1;
                        end
                    end
                FIFO_HAND_WR:
                    begin
                        if (!s_axis.tvalid)
                        begin
                            state_wr <= FIFO_HAND_WR;
                        end else
                        begin
                            state_wr <= FIFO_IDLE_WR;
                            s_axis.tready <= 1'b0;
                            index_wr <= index_wr + 1;
                            mem[index_wr] <= s_axis.tdata;
                        end
                    end
            endcase
        end
    end

    // Logic Flag State
    always_ff @(posedge aclk) 
    begin
        if (!aresetn) 
        begin
            index_rd_wr <= '0;
        end else 
        begin
            if ((state_rd == FIFO_HAND_RD && m_axis.tready && m_axis.tvalid) && (state_wr == FIFO_HAND_WR && s_axis.tready && s_axis.tvalid))
            begin
                index_rd_wr <= index_rd_wr;
            end else if (state_rd == FIFO_HAND_RD && m_axis.tready && m_axis.tvalid)
            begin
                index_rd_wr <= index_rd_wr - 1;
            end else if (state_wr == FIFO_HAND_WR && s_axis.tready && s_axis.tvalid)
            begin
                index_rd_wr <= index_rd_wr + 1;
            end
        end
    end

    assign fifo_empty = (index_wr == index_rd) ? 1 : 0;
    assign fifo_half  = (index_rd_wr > AXI_DATA_DEPTH/2 - 1) ? 1 : 0;
    assign fifo_full  = (index_rd_wr == (AXI_DATA_DEPTH - 1)) ? 1 : 0;

endmodule