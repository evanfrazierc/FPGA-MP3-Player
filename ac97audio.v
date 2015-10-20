`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:53:41 04/03/2011 
// Design Name: 
// Module Name:    ac97audio 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module ac97audio (sys_clk, reset, audio_in_data, audio_out_data,
						ready, audio_on,
						audio_reset_b, ac97_sdata_out, ac97_sdata_in,
                  ac97_synch, ac97_bit_clock, ac97_vol
						);

   input sys_clk;
   input reset;
   input audio_on;
   output [7:0] audio_in_data;
   input [7:0] audio_out_data;
   input [4:0] ac97_vol;
   output ready;

   //ac97 interface signals
   output audio_reset_b;
   output ac97_sdata_out;
   input ac97_sdata_in;
   output ac97_synch;
   input ac97_bit_clock;

   wire [2:0] source;
   assign source = 0;	   //mic
	
   wire [7:0] command_address;
   wire [15:0] command_data;
   wire command_valid;
   wire [19:0] left_in_data, right_in_data;
   wire [19:0] left_out_data, right_out_data;

   reg audio_reset_b;
   reg [9:0] reset_count;

   //wait a little before enabling the AC97 codec
   always @(posedge sys_clk) begin
      if (audio_on) begin
        audio_reset_b = 1'b0;
        reset_count = 0;
      end else if (reset_count == 1023)
        audio_reset_b = 1'b1;
      else
        reset_count = reset_count+1;
   end
	
   wire ac97_ready;
   
   // instantiate ac97 component
	ac97 ac97(.ready(ac97_ready), .command_address(command_address), .command_data(command_data), 
				 .command_valid(command_valid), .left_data(left_out_data), .left_valid(1),
             .right_data(right_out_data), .right_valid(1), .left_in_data(left_in_data), 
				 .right_in_data(right_in_data), .ac97_sdata_out(ac97_sdata_out), .ac97_sdata_in(ac97_sdata_in), 
			    .ac97_synch(ac97_synch), .ac97_bit_clock(ac97_bit_clock), .reset(audio_on)); // was audio_on
	
   // ready: one cycle pulse synchronous with sys_clk
   reg [2:0] ready_sync;
   always @ (posedge sys_clk) begin
     ready_sync <= {ready_sync[1:0], ac97_ready};
   end
   assign ready = ready_sync[1] & ~ready_sync[2];
	
   reg [7:0] out_data;
	
	always @ (posedge sys_clk) begin
		if (ready) begin
			out_data <= audio_out_data;
		end
	end
	
   assign audio_in_data = left_in_data[19:12];
   //assign left_out_data = {audio_in_data, 12'b000000000000}; // Use this for loop back...
   assign left_out_data = {out_data, 12'b000000000000};    // comment this out for loopback
   assign right_out_data = left_out_data;

   // generate repeating sequence of read/writes to AC97 registers
   // instantiate ac97commands component
   
   ac97commands ac97commands(.clock(ac97_bit_clock), .ready(ac97_ready), 
				.command_address(command_address), .command_data(command_data),
            .command_valid(command_valid), .volume(ac97_vol), .source(0));
   
	
endmodule
