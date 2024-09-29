// two port ram, port A use for reading, port B use for writing
module tp_ram_model #(
    parameter WIDTH = 8,
    parameter DEPTH = 8
) (
    input   wire                         clka,
    input   wire                         rena,
    input   wire   [$clog2(DEPTH)-1:0]   addra,
    output  reg    [WIDTH-1:0]           douta,
    
    input   wire                         clkb,
    input   wire                         wenb,
    input   wire   [$clog2(DEPTH)-1:0]   addrb,
    input   wire   [WIDTH-1:0]           dinb
);

reg [WIDTH-1:0] mem [DEPTH];

always @(posedge clkb) begin
    if (wenb) begin
        mem[addrb] <= dinb;
    end
end

always @(posedge clka) begin
    if (rena) begin
        douta <= mem[addra];
    end
end

endmodule