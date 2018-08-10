`timescale 1ns / 1ps

module vga_data_controller
	(
	input 	wire			ptick, //clk olarak ver
	input 	wire			clk,
	input		wire			rst,
	input		wire	[7:0]	pico_addr,
	input		wire	[7:0]	pico_data_in,
	input		wire			pico_write_strobe,
	input		wire			pico_read_strobe,
	input 	wire	[5:0]	x_div,	// x[9:4]
	input		wire	[5:0]	y_div,	// y[9:4]
	
	output	wire	[7:0]	pico_data_out,
	output	wire	[7:0]	vga_out	
	);
	
	reg 		  ram_en;
	wire [7:0] ram_dinb;
	wire [7:0] ram_addrb;
	reg  [7:0] timer;
	(*KEEP="TRUE"*)reg  [7:0] adress;
	wire [7:0] ram_out;
	reg [4:0] ptick_div;
	wire [7:0] calc_addr;
	reg	[7:0] color_out;
	always @(posedge ptick, posedge rst)
	begin
		if(rst) ptick_div <= 0;
		else ptick_div <= ptick_div + 1;
	end
	
	always @ (posedge ptick_div[3], posedge rst)
	begin
		if(rst)
		begin
			ram_en	<= 0;
			adress 	<= 0;
		end
		else
		begin
			
			if ((x_div >= 6'd15) && (x_div < 6'd25) && (y_div < 6'd22) ) 
			begin				
				adress <= calc_addr;
				ram_en	<= 1;
			end
			else
			begin
				adress 	<=  0;
				ram_en 	<=  0;
			end
		end
	end
	
	always@(*)
	begin

		case(ram_out[2:0])
		 3'h7: color_out <= 8'hc4; // L block
		 3'h1: color_out <= 8'h03; // L inverse
		 3'h2: color_out <= 8'he3; // T
		 3'h3: color_out <= 8'he0; // Z
	
		 3'h4: color_out <= 8'h1c; // S
		 3'h5: color_out <= 8'h1B; // I
		 3'h6: color_out <= 8'hFC; // SQ
		 default: color_out <= 8'h00;
	 endcase
		// FOR unicolor uncomment this.
		//if(ram_out[3] == 1) color_out <= 8'hff;
	end
	
	always@(posedge clk)
	begin
		if(rst) timer <= timer + 1;
		else 	timer <= 0;
	end 
	
	assign vga_out = ram_en ? color_out : 8'b01001001;
	
	assign calc_addr = x_div - 6'd15 + (y_div << 3) + (y_div << 1);
	
	assign ram_addrb = rst ? timer : pico_addr;
	
	assign ram_dinb = rst ? 8'h00 : pico_data_in;
	
	my_RAM_2 ourRam (
			.clka(ptick), // input clka
			.wea(1'b0), // input [0 : 0] wea
			.addra(adress), // input [7 : 0] addra
			.dina(8'hZZ), // input [7 : 0] dina
		   .douta(ram_out), // output [7 : 0] douta
			.clkb(clk), // input clkb
			.web(pico_write_strobe|rst), // input [0 : 0] web
			.addrb(ram_addrb), // input [7 : 0] addrb
			.dinb(ram_dinb), // input [7 : 0] dinb
		  .doutb(pico_data_out) // output [7 : 0] doutb
		);	
endmodule
