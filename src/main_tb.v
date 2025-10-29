`timescale 1ns/1ns
`include "main.v"

module four_connect_tb;
	reg clk = 1'b0;
	reg [6:0] pins = 0;
	wire [2:0] col;
	
	
	fourConnect uut(
		.clk(clk),
		.pins(pins),
		.col(col)
	);
	wire ready;
	wire led;

	matrix led_matrix(
		.clk(clk),
		.col(col),
		.ready(ready),
		.led(led)
	);
	

	always #5 clk = ~clk;
	initial begin
		
		$dumpfile("main.vcd");
		$dumpvars(0, uut);
		$dumpvars(0, led_matrix);

		
		#10 pins = 8'b00000001;
		if (col != 1)
			$error("INPUT = 00000001.. expected Column to be 1");
		#10 pins = 8'b00000000;

		#10 pins = 8'b00000100;
		if (col != 3)
			$error("INPUT = 00000001.. expected Column to be 4");
		
		#10 pins = 8'b00000000;
		#50;
		$finish;
	end;
endmodule
