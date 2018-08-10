`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:45:22 05/03/2018
// Design Name:   vga_test
// Module Name:   C:/Users/Asus/Desktop/MSD_Final/Test_system.v
// Project Name:  MSD_Final
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: vga_test
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Test_system;

	// Inputs
	reg clk;
	reg reset;
	reg [7:0] sw;

	// Outputs
	wire hsync;
	wire vsync;
	wire [7:0] rgb;
	wire [7:0] led;

	// Instantiate the Unit Under Test (UUT)
	vga_test uut (
		.clk(clk), 
		.reset(reset), 
		.sw(sw), 
		.hsync(hsync), 
		.vsync(vsync), 
		.rgb(rgb), 
		.led(led)
	);
	always begin #50 clk = ~clk; end
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		sw = 1;

		// Wait 100 ns for global reset to finish
		#100;
		reset = 0;
        
		// Add stimulus here
		sw = 1; #550 sw = 2; #550 sw = 3; 
	end
      
endmodule

