module edge_detect #(
    parameter IMG_WIDTH = 720,
    parameter IMG_HEIGHT = 540
) (
    input  logic        clock,
    input  logic        reset,
    output logic        in_full,
    input  logic        in_wr_en,
    input  logic [23:0] in_din,
    input  logic        out_rd_en,
    output logic [7:0]  out_dout,
    output logic        out_empty
);
//grayscale to sobel
logic grey_out_empty;
logic grey_out_rd_en;
logic [7:0] grey_out_dout;

//sobel to fifo out
logic [7:0] sobel_out;
logic f3_wr_en;
logic f3_full;


grayscale_top #()
grayscale_top_inst(
    .clock(clock),
    .reset(reset),
    .in_full(in_full),
    .in_wr_en(in_wr_en),
    .in_din(in_din),
    .out_empty(grey_out_empty),
    .out_rd_en(grey_out_rd_en),
    .out_dout(grey_out_dout)
);

sobel #(
    .IMG_WIDTH(IMG_WIDTH),
    .IMG_HEIGHT(IMG_HEIGHT)
)
sobel_inst(
    .clock(clock),
    .reset(reset),
    .grey_out_empty(grey_out_empty),
    .grey_out_rd_en(grey_out_rd_en),
    .grey_out_dout(grey_out_dout),
    .sobel_out(sobel_out),
    .f3_wr_en(f3_wr_en),
    .f3_full(f3_full)
);

// fifo out
fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(8)
) fifo_out_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(f3_wr_en),
    .din(sobel_out),
    .full(f3_full),
    .rd_clk(clock),
    .rd_en(out_rd_en),
    .dout(out_dout),
    .empty(out_empty)
);
endmodule