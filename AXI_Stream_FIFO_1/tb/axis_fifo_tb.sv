`timescale 1ns / 1ps

module axis_fifo_tb;

    import pkg_tb::*;

    axis_if #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH)) m_axis();
    axis_if #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH)) s_axis();

    logic aclk;
    logic aresetn;

    logic fifo_empty;
    logic fifo_half;
    logic fifo_full;

    logic   [$clog2(AXI_TRAN_MAX_WAIT)-1:0]     count;
    logic   [1:0]                               flag;

    axis_fifo #
    (
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_DATA_DEPTH(AXI_DATA_DEPTH)        
    )
    
    axis_fifo_inst
    
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .fifo_empty(fifo_empty),
        .fifo_half(fifo_half),
        .fifo_full(fifo_full),
        .m_axis(m_axis),
        .s_axis(s_axis)
    );

    initial
    begin
        aclk = 0;
        forever #5 aclk = ~aclk;
    end

    initial 
    begin
        aresetn = 0;
        #15 aresetn = 1; 
    end

    initial 
    begin
        s_axis.tvalid = 0;
        s_axis.tdata = 0;
        m_axis.tready = 0;

        count = 0;
        flag = 0;
    end

    initial
    begin
        #100;

        fork
            forever
            begin
                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge aclk);
                s_axis.tdata = $random;
                s_axis.tvalid = 1;
                wait(s_axis.tready);
                @(posedge aclk);
                s_axis.tdata = 0;
                s_axis.tvalid = 0;
            end

            forever
            begin
                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge aclk);
                case (flag)
                    0:
                        begin
                            m_axis.tready = 1;
                            wait(m_axis.tvalid);
                            @(posedge aclk)
                            m_axis.tready = 0;
                            flag = $random;
                        end
                    1:
                        begin
                            wait(m_axis.tvalid);
                            @(posedge aclk);
                            m_axis.tready = 1;
                            @(posedge aclk);
                            m_axis.tready = 0;
                            flag = $random;
                        end
                    2:
                        begin
                            if (fifo_full)
                            begin
                                repeat (AXI_DATA_DEPTH*2)
                                begin
                                    @(posedge aclk);
                                    wait(m_axis.tvalid);
                                    m_axis.tready = 1;
                                    @(posedge aclk);
                                    m_axis.tready = 0;
                                    flag = $random;
                                end
                            end else
                            begin
                                wait(m_axis.tvalid);
                                m_axis.tready = 1;
                                @(posedge aclk);
                                m_axis.tready = 0;
                                flag = $random;                                
                            end
                        end
                    3:
                        begin
                            wait(m_axis.tvalid);
                            repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge aclk);
                            m_axis.tready = 1;
                            @(posedge aclk);
                            m_axis.tready = 0;
                            flag = $random;
                        end
                endcase
            end

            forever
            begin
                wait (s_axis.tvalid);
                @(posedge aclk);
                if (m_axis.tvalid)
                begin
                    count = 0;
                end else
                begin
                    if (count != AXI_TRAN_MAX_WAIT)
                    begin
                        count = count + 1;
                    end else
                    begin
                        count = 0;
                        $display("Error: AXI-Stream transaction hang detected!");
                        $finish;
                    end
                end
            end
        join

        $finish;
    end

endmodule