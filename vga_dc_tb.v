`timescale 1ns / 1ps

module vga_dc_TB;

	// Inputs
	reg ptick;
	reg clk;
	reg rst;
	reg [7:0] pico_addr;
	reg [7:0] pico_data_in;
	reg [5:0] x_div;
	reg [5:0] y_div;

	// Outputs
	wire [7:0] pico_data_out;
	wire [7:0] vga_out;

	// Instantiate the Unit Under Test (UUT)
	vga_data_controller uut (
		.ptick(ptick), 
		.clk(clk), 
		.rst(rst), 
		.pico_addr(pico_addr), 
		.pico_data_in(pico_data_in), 
		.x_div(x_div), 
		.y_div(y_div), 
		.pico_data_out(pico_data_out), 
		.vga_out(vga_out)
	);

	initial begin
		// Initialize Inputs
		ptick = 0;
		clk = 0;
		rst = 0;
		pico_addr = 0;
		pico_data_in = 0;
		x_div = 0;
		y_div = 0;

		// Wait 100 ns for global reset to finish
		#100;
      rst = 1; 
		// Add stimulus here
		#50
		rst = 0;
		x_div = 20; 
		y_div = 15;
		#50
		x_div = 18; 
		y_div = 16;
		#50
		x_div = 19; 
		y_div = 15;
		#50
		x_div = 20; 
		y_div = 19;
		#50
		x_div = 21; 
		y_div = 15;
		#50
		x_div = 22; 
		y_div = 15;
		#50
		x_div = 23; 
		y_div = 21;
		#50
		x_div = 24; 
		y_div = 15;
		#50
		x_div = 100; 
		y_div = 17;
		#50
		x_div = 0; 
		y_div = 0;
		
		
	end
   
	always begin clk = ~clk; 	  #50; end
	always begin ptick = ~ptick; 	  #50; end
	//always begin ptick = ~ptick; #100; end
	
	
endmodule

