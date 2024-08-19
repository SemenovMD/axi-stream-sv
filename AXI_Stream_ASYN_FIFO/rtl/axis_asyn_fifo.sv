module axis_asyn_fifo

#(
    parameter   AXI_DATA_WIDTH  =   32,
    parameter   AXI_DATA_DEPTH  =   32
)

(
    input   logic                                       aclk_wr,
    input   logic                                       aresetn_wr,
    input   logic                                       aclk_rd,
    input   logic                                       aresetn_rd,
    output  logic                                       fifo_empty,
    output  logic                                       fifo_full,

    axis_if.m_axis                                      m_axis,
    axis_if.s_axis                                      s_axis
);

    logic           [AXI_DATA_WIDTH-1:0]                mem             [AXI_DATA_DEPTH];

    logic           [$clog2(AXI_DATA_DEPTH)-1:0]        bin_index_rd;
    logic           [$clog2(AXI_DATA_DEPTH)-1:0]        bin_index_wr;

    logic           [$clog2(AXI_DATA_DEPTH)-1:0]        gray_index_rd;
    logic           [$clog2(AXI_DATA_DEPTH)-1:0]        gray_index_wr;

    logic           [$clog2(AXI_DATA_DEPTH)-1:0]        gray_index_rd_sync;
    logic           [$clog2(AXI_DATA_DEPTH)-1:0]        gray_index_wr_sync;

    logic           [$clog2(AXI_DATA_DEPTH)-1:0]        q1_wr;
    logic           [$clog2(AXI_DATA_DEPTH)-1:0]        q1_rd;

    // Converter Binary -> Gray index WRITE
    always_comb
    begin
        gray_index_wr = (bin_index_wr >> 1) ^ bin_index_wr;
    end

    // Converter Binary -> Gray index READ
    always_comb
    begin
        gray_index_rd = (bin_index_rd >> 1) ^ bin_index_rd;
    end

    // Synchronizer WRITE
    always @(posedge aclk_wr)
    begin
        if (!aresetn_wr)
        begin
            q1_rd <= '0;
            gray_index_rd_sync <= '0;
        end else
        begin
            q1_rd <= gray_index_rd;
            gray_index_rd_sync <= q1_rd;
        end
    end

    // Synchronizer READ
    always @(posedge aclk_rd)
    begin
        if (!aresetn_rd)
        begin
            q1_wr <= '0;
            gray_index_wr_sync <= '0;
        end else
        begin
            q1_wr <= gray_index_wr;
            gray_index_wr_sync <= q1_wr;
        end
    end

    // FSM WRITE
    typedef enum logic
    {  
        IDLE_WR,
        HAND_WR
    } state_type_wr;

    state_type_wr state_wr;

    always @(posedge aclk_wr)
    begin
        if (!aresetn_wr)
        begin
            state_wr <= IDLE_WR;
            s_axis.tready <= 0;
            bin_index_wr <= '0;
        end else
        begin
            case (state_wr)
                IDLE_WR:
                    begin
                        if (fifo_full)
                        begin
                            state_wr <= IDLE_WR;
                        end else
                        begin
                            state_wr <= HAND_WR;
                            s_axis.tready <= 1;
                        end
                    end
                HAND_WR:
                    begin
                        if (!s_axis.tvalid)
                        begin
                            state_wr <= HAND_WR;
                        end else
                        begin
                            state_wr <= IDLE_WR;
                            s_axis.tready <= 0;
                            bin_index_wr <= bin_index_wr + 1;
                            mem[bin_index_wr] <= s_axis.tdata;
                        end
                    end
            endcase
        end
    end

    // FSM READ
    typedef enum logic
    {  
        IDLE_RD,
        HAND_RD
    } state_type_rd;

    state_type_rd state_rd;

    always @(posedge aclk_rd)
    begin
        if (!aresetn_rd)
        begin
            state_rd <= IDLE_RD;
            m_axis.tdata <= '0;
            m_axis.tvalid <= 0;
            bin_index_rd <= '0;
        end else
        begin
            case (state_rd)
                IDLE_RD:
                    begin
                        if (fifo_empty)
                        begin
                            state_rd <= IDLE_RD;
                        end else
                        begin
                            state_rd <= HAND_RD;
                            m_axis.tdata <= mem[bin_index_rd];
                            m_axis.tvalid <= 1;
                        end
                    end
                HAND_RD:
                    begin
                        if (!m_axis.tready)
                        begin
                            state_rd <= HAND_RD;
                        end else
                        begin
                            state_rd <= IDLE_RD;
                            m_axis.tdata <= '0;
                            m_axis.tvalid <= 0;
                            bin_index_rd <= bin_index_rd + 1;
                        end
                    end
            endcase
        end
    end

    // Logic FIFO full and empty
    assign fifo_empty   = (gray_index_wr_sync == gray_index_rd);
    assign fifo_full    = (gray_index_wr == {~gray_index_rd_sync[$clog2(AXI_DATA_DEPTH)-1:$clog2(AXI_DATA_DEPTH)-1], gray_index_rd_sync[$clog2(AXI_DATA_DEPTH)-2:0]});

endmodule