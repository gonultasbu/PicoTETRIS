`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:24:42 04/04/2018 
// Design Name: 
// Module Name:    LFSR 
// Project Name: 
// Target Devices: l
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 9'b1_0111_0001
//
//////////////////////////////////////////////////////////////////////////////////
module LFSR3 #(parameter polinom = 9'b1_0111_0001)(clk, rst, ctextIn, zOut,seed);

	input [7:0]		seed;
	input				clk;
	input				rst;
	input				ctextIn;
	output [7:0]		zOut;

	(*KEEP="TRUE"*)reg 	[7:0] 	ffs;
	(*KEEP="TRUE"*)reg	[7:0]		ctext_reg;
						reg	[3:0]		counter;
	assign zOut = ffs;
	
	assign feedback = 	// Classic LSFR.
								(polinom[1] && ffs[0]) ^ 
								(polinom[2] && ffs[1]) ^ 
								(polinom[3] && ffs[2]) ^ 
								(polinom[4] && ffs[3]) ^ 
								(polinom[5] && ffs[4]) ^ 
								(polinom[6] && ffs[5]) ^ 
								(polinom[7] && ffs[6]) ^ 
								(polinom[8] && ffs[7]) | 
								// All zero protection.
								!(	ffs[0] | ffs[1] | 
									ffs[2] | ffs[3] | 
									ffs[4] | ffs[5] | 
									ffs[6] | ffs[7]
								);						
								

	always@(posedge clk or posedge rst)
	begin
		if(rst)
		begin
			ffs 			<= seed;	// starting seed to protect first 8 bytes.
			ctext_reg 	<= 8'h00;
			counter		<= 4'h0;
		end
		else
		begin
			counter <= counter + 1;
			if(counter == 4'h8)	// In every 8 cycle take ciphertext as seed.
										// Which means any error will be corrected after 8 errorless cycles.
			begin
				ffs <= ctext_reg;
			end
			else
			begin
				ffs <= {ffs[6:0],feedback};				
			end
			ctext_reg <= {ctext_reg[6:0],ctextIn};
		end
	end
endmodule
