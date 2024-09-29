// single port ram
module sp_ram_model #(
    parameter WIDTH = 8,
    parameter DEPTH = 8
) (
    input   wire                         clk,
    input   wire                         en,
    input   wire                         wen,
    input   wire   [$clog2(DEPTH)-1:0]   addr,
    input   wire   [WIDTH-1:0]           din,
    output  reg    [WIDTH-1:0]           dout
);

reg [WIDTH-1:0] mem [DEPTH];
always @(posedge clk) begin
    if (en) begin
        if (wen) begin
            mem[addr] <= din;
        end
        else begin
            dout <= mem[addr];
        end
    end
end

endmodule