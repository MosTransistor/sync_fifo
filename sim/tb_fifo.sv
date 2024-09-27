`timescale 1ns/1ps

module tb_fifo();

    initial begin
        $dumpfile("sync_fifo.vcd");
        $dumpvars(0, tb_fifo);
    end

    logic           t_clk=0;
    logic           t_rst_n=0;
    
    logic           t_wr=0;
    logic  [31:0]   t_din=0;
    logic           t_rd=0;
    logic  [31:0]   t_dout;
    logic  [3:0]    t_used_cnt;
    logic           t_full;
    logic           t_empty;
    
    logic [31:0]  ref_data[$];
    logic [31:0]  imp_data[$];
    logic t_rd_s;
    integer fh, seed;

    always #5 t_clk = ~t_clk;
    
    always @(posedge t_clk) begin
        t_rd_s <= t_rd;
        if (t_wr)  ref_data.push_back(t_din);
        if (t_rd_s) imp_data.push_back(t_dout);
    end

    initial begin
        fh = $fopen("random.txt", "r");
        $fscanf(fh, "%d", seed);
        $fclose(fh);

        $display(" [INFO] simulation begin");
        repeat (2) @(negedge t_clk);
        t_rst_n = 1;

        repeat (20000) begin
            repeat (1) @(negedge t_clk);
            case ({t_full, t_empty})
                2'b00: begin t_wr = $urandom(seed); t_din = $urandom(seed); t_rd = $urandom(seed); end
                2'b01: begin t_wr = $urandom(seed); t_din = $urandom(seed); t_rd = 1'b0; end
                2'b10: begin t_wr = 1'b0; t_din = $urandom(seed); t_rd = $urandom(seed); end
                2'b11: begin $display("\033[31m [FAIL] FIFO empty and full both equal to 1 \033[0m"); $finish; end
            endcase
        end

        repeat (1) @(negedge t_clk);
        while(!t_empty) begin
            repeat (1) @(negedge t_clk);
            t_wr = 1'b0; 
            t_din = $urandom(seed); 
            t_rd = $urandom(seed);
        end

        repeat (3) @(negedge t_clk);
        $display(" [INFO] first data ref = %h, imp = %h",ref_data[0],imp_data[0]);
        foreach (ref_data[i]) begin
            if (ref_data[i] !== imp_data[i]) begin
                $display("\033[31m [FAIL] last transfer = %h, ref_payload = %h, imp_payload = %h \033[0m",i-1,ref_data[i-1],imp_data[i-1]);
                $display("\033[31m [FAIL] current transfer = %h, ref_payload = %h, imp_payload = %h \033[0m",i,ref_data[i],imp_data[i]);
                $finish;
            end
        end
        $display("\033[32m [PASS] simulation pass!!! \033[0m");
        $finish;
    end   

    sync_fifo_spram #(.WIDTH(32), .DEPTH(15))  i_sync_fifo(.clk(t_clk), .rst_n(t_rst_n), 
                                  .wr(t_wr), .din(t_din), .rd(t_rd), .dout(t_dout),
                                  .used_cnt(t_used_cnt), .empty(t_empty), .full(t_full));

endmodule