`timescale 1ns / 1ps
module uart_tb();
reg clk, rst_n;
initial begin
    clk = 'b0;
    forever #10 clk = ~clk;
end

initial begin
    rst_n = 'b1;
    #10
    rst_n = 'b0;
    #10
    rst_n = 'b1;
end

initial begin
    $dumpfile("wave.vcd");
    $dumpvars();
    #8000 $finish;
end

reg wen, ren;
reg [7:0] wdata;
wire [7:0] rdata;
wire full, empty;

initial begin
    wen = 'b0;
    ren = 'b0;
    wdata = 'h00;
    #50
    repeat (8) @(negedge clk) begin
        wen = 'b1;
        wdata = $random;
    end
    wen = 'b0;
    forever @(negedge clk) begin
        if (!empty) begin
            ren = 'b1;
        end
        else begin
            ren = 'b0;
        end
    end
end

// loopback test
wire tx;
uart #(
    .CLK_FREQ           (50_000_000),
    .BAUD               (12_000_000),   /* This baudrate is for testing purposes only */
    .FIFO_DEPTH         (8)
) uart0(
    .clk                (clk),
    .rst_n              (rst_n),

    .i_txfifo_wen       (wen),
    .o_txfifo_full      (full),
    .i_txfifo_wdata     (wdata),
    .o_txfifo_cnt       (),

    .i_rxfifo_ren       (ren),
    .o_rxfifo_empty     (empty),
    .o_rxfifo_rdata     (rdata),
    .o_rxfifo_cnt       (),

    .i_rx               (tx),
    .o_tx               (tx)
);
endmodule
