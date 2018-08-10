`timescale 1ns / 1ps

// VGA_sycn icin ram yazilacak 
// butonlarin debounce olayina bakmak gerek 
// butonlara fonksiyonlar assign edilecek 
// surekli cisim dusecek yapilabilir  

module vga_test(
		input wire  clk, reset,
		input wire  [7:0] sw,
		output wire hsync, vsync,
		output wire [7:0] rgb,
		output wire [7:0] led
	);
	
		wire 		[9:0] 	x, y;
		wire		[5:0]		x_div,y_div;
		wire 		[9:0] 	address;
		wire 		[17:0] 	instruction;
		wire 		[7:0] 	port_id;
		wire 					write_strobe;
		wire 		[7:0] 	out_port;
		wire 					read_strobe;
		reg 		[7:0] 	in_port;
		reg		[7:0]		seed;
		reg 		[7:0] 	ctextIn;
		reg		[7:0]		ttime;
		wire		[7:0]		zOut;
		wire		[7:0]		pico_data_out;

		
		wire rst;
		assign rst = reset;
		
	msdv5 program (
    .address(address), 
    .instruction(instruction), 
    .clk(clk)
    );
	// Instantiate the module
	
	LFSR3 My_RNG (
    .clk(clk), 
    .rst(rst), 
    .ctextIn(ctextIn), 
    .zOut(zOut), 
    .seed(seed)
    );
	 
	always@(posedge clk or posedge rst) 
	begin
		if(rst)
		begin
			seed <= 0;
			ctextIn <= 0;
			ttime <= 0;
		end
		else
		begin
			if (ttime==6) begin
			ttime <= 0;
			end
			else begin
			ttime <= ttime + 1;
			end
			seed <= seed + 1;
			ctextIn <= ctextIn + 3;
		end
	end
	
	kcpsm3 my_pico (
    .address(address), 
    .instruction(instruction), 
    .port_id(port_id), 
    .write_strobe(write_strobe), 
    .out_port(out_port), 
    .read_strobe(read_strobe), 
    .in_port(in_port), 
    .interrupt(interrupt), 
    .interrupt_ack(interrupt_ack), 
    .reset(rst), 
    .clk(clk)
    );	 
	
	// register for Basys 2 8-bit RGB DAC 
	reg [7:0] rgb_reg;
	reg [7:0] led_reg;
	// video status output from vga_sync to tell when to route out rgb signal to DAC
	wire video_on;
	wire [7:0] vga_out;
	// VGA data control, edge detection
	
	vga_data_controller vga_control (
    .ptick(ptick), 
    .clk(clk), 
    .rst(rst), 
    .pico_addr(port_id), 
    .pico_data_in(out_port), 
	 .pico_write_strobe(write_strobe),
	 .pico_read_strobe(read_strobe),
    .x_div(x_div), 
    .y_div(y_div), 
    .pico_data_out(pico_data_out), 
    .vga_out(vga_out)
    );
	 
	assign x_div 	  = x[9:4]; // divide to 16 for pixel implementation
	assign y_div	  = y[9:4]; // divide to 16 for pixel implementation
	
    // instantiate vga_sync
   vga_sync vga_sync_unit (.clk(clk), 
									.reset(rst), 
									.hsync(hsync), 
									.vsync(vsync),
                           .video_on(video_on), 
									.p_tick(ptick), 
									.x(x), 
									.y(y)
									);
									  
	//assign Led = {clk, reset, hsync, vsync, video_on};
		
   // rgb buffer
   always @(posedge clk or posedge rst)
   if (rst)
	  rgb_reg <= 0;
   else 
	begin
		rgb_reg <= vga_out;
		case(port_id)
		8'hFD: led_reg <=out_port;
		8'hFE: in_port <= sw; //Read buttons
		8'hFF: in_port <= ttime;
		default: if(read_strobe == 1) in_port <= pico_data_out;
		endcase
	end  
   // output
   assign rgb = (video_on) ? rgb_reg : 8'b0;
	assign led = led_reg;
	
endmodule
