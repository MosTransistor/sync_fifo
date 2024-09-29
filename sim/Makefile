sim:
	echo $$RANDOM > random.txt
	iverilog -g2012 -o sim.o  ./tb_fifo.sv ../src/sync_fifo_spram.v ../src/sp_ram_model.v ../src/sync_fifo_tpram.v ../src/tp_ram_model.v
	vvp sim.o

wave:
	gtkwave *.vcd

clean:
	rm -rf *.o *.vcd random.txt