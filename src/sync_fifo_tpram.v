`define RD 1ns
module sync_fifo_tpram #(
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
    output   wire  [$clog2(DEPTH):0]    used_cnt,
    output   wire                       full,
    output   wire                       empty
);

localparam AW = $clog2(DEPTH);

wire  [AW:0]       used_cnt_c; 
reg   [AW:0]       used_cnt_s; 

wire  [AW-1:0]     waddr_c;
reg   [AW-1:0]     waddr_r;
wire  [AW-1:0]     raddr_c;
reg   [AW-1:0]     raddr_r;

wire               ram_wr;
wire  [AW-1:0]     ram_wr_addr;
wire  [WIDTH-1:0]  ram_wdata;
wire               ram_rd;
wire  [AW-1:0]     ram_rd_addr;
wire  [WIDTH-1:0]  ram_rdata;

// FIFO data counter
assign used_cnt_c = wr ? (rd ? used_cnt_s : used_cnt_s + 1'b1) : (rd ? used_cnt_s - 1'b1 : used_cnt_s);

// FIFO pointer 
assign waddr_c = wr ? ((waddr_r == DEPTH-1) ? {AW{1'b0}} : waddr_r + 1'b1) : waddr_r;
assign raddr_c = rd ? ((raddr_r == DEPTH-1) ? {AW{1'b0}} : raddr_r + 1'b1) : raddr_r;

// RAM interface
assign ram_wr = wr;
assign ram_wr_addr = waddr_r;
assign ram_wdata = din;
assign ram_rd = rd;
assign ram_rd_addr = raddr_r;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        used_cnt_s    <= #`RD {(AW+1){1'b0}};
        waddr_r       <= #`RD {AW{1'b0}};
        raddr_r       <= #`RD {AW{1'b0}};
    end
    else begin
        used_cnt_s    <= #`RD used_cnt_c;
        waddr_r       <= #`RD waddr_c;
        raddr_r       <= #`RD raddr_c;
    end
end

// FIFO output
assign dout  = ram_rdata;
assign full  = (used_cnt_s == DEPTH);
assign empty = (used_cnt_s == 0);
assign used_cnt = used_cnt_s;

tp_ram_model #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH)
) 
data_ram(
    .clka(clk),
    .rena(ram_rd),
    .addra(ram_rd_addr),
    .douta(ram_rdata),
    .clkb(clk),
    .wenb(ram_wr),
    .addrb(ram_wr_addr),
    .dinb(ram_wdata)
);

endmodule