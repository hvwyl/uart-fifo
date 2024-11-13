module uart_fifo #(
    parameter FIFO_WIDTH = 8,
    parameter FIFO_DEPTH = 8
) (
    input clk,
    input rst_n,

    input                               i_fifo_wen,
    input                               i_fifo_ren,
    output                              o_fifo_full,
    output                              o_fifo_empty,

    input [FIFO_WIDTH-1:0]              i_fifo_wdata,
    output reg [FIFO_WIDTH-1:0]         o_fifo_rdata,

    output reg [$clog2(FIFO_DEPTH):0]   o_fifo_cnt
);
    /* an implementation of a synchronous fifo */
    reg [FIFO_WIDTH-1:0] buffer [FIFO_DEPTH-1:0];
    reg [$clog2(FIFO_DEPTH)-1:0] wptr;
    reg [$clog2(FIFO_DEPTH)-1:0] rptr;

    assign o_fifo_full = (o_fifo_cnt==FIFO_DEPTH);
    assign o_fifo_empty = (o_fifo_cnt=='d0);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wptr <= 'd0;
            rptr <= 'd0;
            o_fifo_cnt <= 'd0;
        end
        else begin
            if (i_fifo_wen && !o_fifo_full) begin
                wptr <= wptr + 'd1;
                buffer[wptr] <= i_fifo_wdata;
            end
            if (i_fifo_ren && !o_fifo_empty) begin
                rptr <= rptr + 'd1;
                o_fifo_rdata <= buffer[rptr];
            end
            case ({i_fifo_wen, i_fifo_ren})
                'b01: if (o_fifo_cnt!='d0) begin
                    o_fifo_cnt <= o_fifo_cnt - 'd1;
                end
                'b10: if (o_fifo_cnt!=FIFO_DEPTH) begin
                    o_fifo_cnt <= o_fifo_cnt + 'd1;
                end
                default: o_fifo_cnt <= o_fifo_cnt;
            endcase
        end
    end
endmodule