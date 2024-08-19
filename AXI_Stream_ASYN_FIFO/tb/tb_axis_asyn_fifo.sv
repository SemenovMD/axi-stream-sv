module tb_axis_asyn_fifo;

    // Параметры для FIFO
    parameter AXI_DATA_WIDTH = 32;
    parameter AXI_DATA_DEPTH = 32;

    // Входные и выходные сигналы
    logic aclk_wr;
    logic aresetn_wr;
    logic aclk_rd;
    logic aresetn_rd;

    logic fifo_empty;
    logic fifo_full;

    axis_if m_axis();
    axis_if s_axis();

    // Инстанцирование FIFO
    axis_asyn_fifo #
    (
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_DATA_DEPTH(AXI_DATA_DEPTH)
    ) 
    
    axis_asyn_fifo_inst
    
    (
        .aclk_wr(aclk_wr),
        .aresetn_wr(aresetn_wr),
        .aclk_rd(aclk_rd),
        .aresetn_rd(aresetn_rd),
        .m_axis(m_axis),
        .s_axis(s_axis),
        .fifo_empty(fifo_empty),
        .fifo_full(fifo_full)
    );

    // Тактовые сигналы для записи и чтения
    initial begin
        aclk_wr = 0;
        forever #20 aclk_wr = ~aclk_wr;  // Период тактового сигнала записи 10 ед. времени
    end

    initial begin
        aclk_rd = 0;
        forever #1 aclk_rd = ~aclk_rd;  // Период тактового сигнала чтения 14 ед. времени
    end

    // Сброс сигналов
    initial begin
        aresetn_wr = 0;
        aresetn_rd = 0;
        #50;
        aresetn_wr = 1;
        aresetn_rd = 1;
    end

    initial 
    begin
        s_axis.tvalid = 0;
        s_axis.tdata = 0;
        m_axis.tready = 0;
    end

    initial
    begin
        #100;

        forever
        begin
            @(posedge aclk_wr);
            @(posedge aclk_wr);
            s_axis.tdata = $random;
            s_axis.tvalid = 1;
            wait(s_axis.tready);
            @(posedge aclk_wr);
            s_axis.tdata = '0;
            s_axis.tvalid = 0;
            @(posedge aclk_wr);
            @(posedge aclk_wr);
        end
    end

    initial
    begin
        #100;

        forever
        begin
            wait(fifo_full);
            repeat (10) @(posedge aclk_rd);
            repeat (AXI_DATA_DEPTH)
            begin
                @(posedge aclk_rd);
                wait(m_axis.tvalid)
                @(posedge aclk_rd);
                m_axis.tready = 1;
                @(posedge aclk_rd);
                m_axis.tready = 0;
                @(posedge aclk_rd);
                @(posedge aclk_rd);
            end
        end
    end

endmodule
