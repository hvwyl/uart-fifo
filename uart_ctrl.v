module uart_ctrl (
    input       clk,
    input       rst_n,

    output      o_txfifo_ren,
    input       i_txfifo_empty,
    output      o_rxfifo_wen,
    input       i_rxfifo_full,

    output      o_tx_valid,
    input       i_tx_ready,
    output      o_rx_ready,
    input       i_rx_valid
);
    reg tx_wait;
    assign o_txfifo_ren = (!tx_wait && !i_txfifo_empty && i_tx_ready);
    assign o_tx_valid = tx_wait;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_wait <= 'b0;
        end
        else if (o_txfifo_ren) begin
            tx_wait <= 'b1;
        end
        else if (!i_tx_ready) begin
            tx_wait <= 'b0;
        end
    end

    reg rx_wait;
    assign o_rxfifo_wen = (rx_wait && i_rx_valid);
    assign o_rx_ready = (!rx_wait && !i_rxfifo_full);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_wait <= 'b1;
        end
        else if (o_rxfifo_wen) begin
            rx_wait <= 'b0;
        end
        else if (!i_rxfifo_full) begin
            rx_wait <= 'b1;
        end
    end
endmodule