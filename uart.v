module uart #(
    parameter CLK_FREQ      = 50_000_000,
    parameter BAUD          = 115200,
    parameter FIFO_DEPTH    = 8
) (
    input       clk,
    input       rst_n,

    input                           i_txfifo_wen,
    output                          o_txfifo_full,
    input [7:0]                     i_txfifo_wdata,
    output [$clog2(FIFO_DEPTH):0]   o_txfifo_cnt,

    input                           i_rxfifo_ren,
    output                          o_rxfifo_empty,
    output [7:0]                    o_rxfifo_rdata,
    output [$clog2(FIFO_DEPTH):0]   o_rxfifo_cnt,

    output                          o_tx,
    input                           i_rx
);
    wire txfifo_ren;
    wire txfifo_empty;
    wire [7:0] txfifo_rdata;
    uart_fifo #(
        .FIFO_WIDTH     (8),
        .FIFO_DEPTH     (FIFO_DEPTH)
    ) uart_fifo_tx(
        .clk            (clk),
        .rst_n          (rst_n),

        .i_fifo_wen     (i_txfifo_wen),
        .i_fifo_ren     (txfifo_ren),
        .o_fifo_full    (o_txfifo_full),
        .o_fifo_empty   (txfifo_empty),

        .i_fifo_wdata   (i_txfifo_wdata),
        .o_fifo_rdata   (txfifo_rdata),

        .o_fifo_cnt     (o_txfifo_cnt)
    );
    wire rxfifo_wen;
    wire rxfifo_full;
    wire [7:0] rxfifo_wdata;
    uart_fifo #(
        .FIFO_WIDTH     (8),
        .FIFO_DEPTH     (FIFO_DEPTH)
    ) uart_fifo_rx(
        .clk            (clk),
        .rst_n          (rst_n),

        .i_fifo_wen     (rxfifo_wen),
        .i_fifo_ren     (i_rxfifo_ren),
        .o_fifo_full    (rxfifo_full),
        .o_fifo_empty   (o_rxfifo_empty),

        .i_fifo_wdata   (rxfifo_wdata),
        .o_fifo_rdata   (o_rxfifo_rdata),

        .o_fifo_cnt     (o_rxfifo_cnt)
    );
    wire tx_valid;
    wire tx_ready;
    wire rx_ready;
    wire rx_valid;
    uart_intf #(
        .CLK_FREQ       (CLK_FREQ),
        .BAUD           (BAUD)
    ) uart_intf_0(
        .clk            (clk),
        .rst_n          (rst_n),

        .i_tx_valid     (tx_valid),
        .i_tx_data      (txfifo_rdata),
        .o_tx_ready     (tx_ready),

        .i_rx_ready     (rx_ready),
        .o_rx_data      (rxfifo_wdata),
        .o_rx_valid     (rx_valid),

        .o_tx           (o_tx),
        .i_rx           (i_rx)
    );
    uart_ctrl uart_ctrl_0(
        .clk            (clk),
        .rst_n          (rst_n),

        .o_txfifo_ren   (txfifo_ren),
        .i_txfifo_empty (txfifo_empty),
        .o_rxfifo_wen   (rxfifo_wen),
        .i_rxfifo_full  (rxfifo_full),

        .o_tx_valid     (tx_valid),
        .i_tx_ready     (tx_ready),
        .o_rx_ready     (rx_ready),
        .i_rx_valid     (rx_valid)
    );
endmodule