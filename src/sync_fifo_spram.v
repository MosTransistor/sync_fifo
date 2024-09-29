`define RD 1ns
module sync_fifo_spram #(
    parameter WIDTH = 8,
    parameter DEPTH = 8
) (
    // global signal
    input    wire                       clk,
    input    wire                       rst_n,

    // FIFO interface
    input    wire                       wr,
    input    wire  [WIDTH-1:0]          din,
    input    wire                       rd,
    output   wire  [WIDTH-1:0]          dout,
    output   wire  [$clog2(DEPTH)-1:0]  used_cnt,
    output   wire                       full,
    output   wire                       empty
);

localparam AW = $clog2(DEPTH);
localparam DEPTH_HALF = (DEPTH % 2 == 1) ? DEPTH / 2 + 1 : DEPTH / 2;

wire  [AW-1:0]     used_cnt_c; 
reg   [AW-1:0]     used_cnt_s; 

wire  [AW-1:0]     waddr_c;
reg   [AW-1:0]     waddr_r;
wire  [AW-1:0]     raddr_c;
reg   [AW-1:0]     raddr_r;

wire               in2latch;
wire               latch2ram;
wire               in2ram;
wire  [WIDTH-1:0]  data_latch_c;
reg   [WIDTH-1:0]  data_latch_s;
wire               latch_valid_c;
reg                latch_valid_s;

wire               even_ram_cs;
wire               even_ram_wr;
wire  [AW-2:0]     even_ram_addr;
wire  [WIDTH-1:0]  even_ram_wdata;
wire  [WIDTH-1:0]  even_ram_rdata;

wire               odd_ram_cs;
wire               odd_ram_wr;
wire  [AW-2:0]     odd_ram_addr;
wire  [WIDTH-1:0]  odd_ram_wdata;
wire  [WIDTH-1:0]  odd_ram_rdata;


// FIFO data counter
assign used_cnt_c = wr ? (rd ? used_cnt_s : used_cnt_s + 1'b1) : (rd ? used_cnt_s - 1'b1 : used_cnt_s);

//
assign in2latch = wr & rd & ((waddr_r[0] == raddr_r[0]) |  latch_valid_s);
assign data_latch_c = in2latch ? din : data_latch_s;
assign latch_valid_c = in2latch ? 1'b1 : 1'b0;
assign latch2ram = latch_valid_s;
assign in2ram = wr & (~in2latch);

// FIFO pointer 
assign waddr_c = (latch2ram || in2ram) ? waddr_r + latch2ram + in2ram : waddr_r;
assign raddr_c = rd ? raddr_r + 1'b1 : raddr_r;

// RAM interface
assign even_ram_cs = (rd & (~raddr_r[0])) | even_ram_wr;
assign even_ram_wr = (latch2ram & (~waddr_r[0])) | (in2ram & ((~waddr_r[0]) | latch2ram));
assign even_ram_addr = (!even_ram_wr) ? raddr_r[AW-1:1] :
                       (latch2ram && in2ram && waddr_r[0]) ? waddr_r + 1'b1 >> 1 : waddr_r[AW-1:1];
assign even_ram_wdata = (latch2ram && (!waddr_r[0])) ? data_latch_s : din;

assign odd_ram_cs = (rd & raddr_r[0]) | odd_ram_wr;
assign odd_ram_wr = (latch2ram & waddr_r[0]) | (in2ram & (waddr_r[0] | latch2ram));
assign odd_ram_addr = (!odd_ram_wr) ? raddr_r[AW-1:1] : 
                      (latch2ram && in2ram && (!waddr_r[0])) ? waddr_r + 1'b1 >> 1 : waddr_r[AW-1:1];
assign odd_ram_wdata = (latch2ram && waddr_r[0]) ? data_latch_s : din;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        used_cnt_s    <= #`RD {AW{1'b0}};
        waddr_r       <= #`RD {AW{1'b0}};
        raddr_r       <= #`RD {AW{1'b0}};
        latch_valid_s <= #`RD 1'b0;
        data_latch_s  <= #`RD {WIDTH{1'b0}};
    end
    else begin
        used_cnt_s    <= #`RD used_cnt_c;
        waddr_r       <= #`RD waddr_c;
        raddr_r       <= #`RD raddr_c;
        latch_valid_s <= #`RD latch_valid_c;
        data_latch_s  <= #`RD data_latch_c;
    end
end

// FIFO output
assign dout  = raddr_r[0] ? even_ram_rdata : odd_ram_rdata;
assign full  = (used_cnt_s == DEPTH);
assign empty = (used_cnt_s == 0);
assign used_cnt = used_cnt_s;

sp_ram_model #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH_HALF)
) 
odd_ram(
    .clk(clk),
    .en(odd_ram_cs),
    .wen(odd_ram_wr),
    .addr(odd_ram_addr),
    .din(odd_ram_wdata),
    .dout(odd_ram_rdata)
);

sp_ram_model #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH_HALF)
) 
even_ram(
    .clk(clk),
    .en(even_ram_cs),
    .wen(even_ram_wr),
    .addr(even_ram_addr),
    .din(even_ram_wdata),
    .dout(even_ram_rdata)
);

endmodule