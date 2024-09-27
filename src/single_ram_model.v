module single_ram_model #(
    parameter WIDTH = 8,
    parameter DEPTH = 8
) (
    input   wire                         clk,
    input   wire                         cs,
    input   wire                         wr,
    input   wire   [$clog2(DEPTH)-1:0]   addr,
    input   wire   [WIDTH-1:0]           wdata,
    output  reg    [WIDTH-1:0]           rdata
);

reg [WIDTH-1:0] mem [DEPTH];
always @(posedge clk) begin
    if (cs) begin
        if (wr) begin
            mem[addr] <= wdata;
        end
        else begin
            rdata <= mem[addr];
        end
    end
end

endmodule