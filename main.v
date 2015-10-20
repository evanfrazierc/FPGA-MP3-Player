`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    loopback 
//////////////////////////////////////////////////////////////////////////////////

module main(reset, clk, up_btn, dwn_btn, sel_btn, lft_btn, rht_btn, lcd_enb, lcd_rs, lcd_rw, lcd_data);
	
	// Control -> clk, rst, etc
	input reset; // Remember: ACTIVE LOW!!!
	input clk; // 100 MHz
	input up_btn; // LOC N4
	input dwn_btn; // LOC P3
	input sel_btn; // LOC F5
	input lft_btn;	// LOC P4
	input rht_btn; // LOC F6
	
    // LCD 
	reg lcd_wrt_ack;
    output reg lcd_enb, lcd_rs, lcd_rw;
    output reg[3:0] lcd_data;
	wire fsm_wrt_req;
	wire[7:0] lcd_nxt_state;
     
	// PicoBlaze Data Lines
	wire [7:0]pb_port_id;
	wire [7:0]pb_out_port;
	reg [7:0]pb_in_port;
	wire pb_read_strobe;
	wire pb_write_strobe;
	
	// PicoBlaze CPU Control Wires
	wire pb_reset;
	wire pb_interrupt;
	wire pb_int_ack;

	
	// PB expects ACTIVE-HIGH reset
    assign pb_reset = ~reset;
	
	// Disable interrupt by assigning 0 to interrupt
	assign pb_interrupt = 1'b0;
	
	// Debounce external push-button inputs
	wire cln_upBtn;
	wire cln_dwnBtn;
	wire cln_selBtn;
	wire cln_lftBtn;
	wire cln_rhtBtn;


    wire sysClk;
    clock_33MHz sys_clk (.clk(clk), .reset(pb_reset), .clk_out(sysClk));

	// instances
	debounce up_button (.reset(reset), .clk(sysClk), .noisy(up_btn), .clean(cln_upBtn));
	debounce dwn_button (.reset(reset), .clk(sysClk), .noisy(dwn_btn), .clean(cln_dwnBtn));
	debounce sel_button (.reset(reset), .clk(sysClk), .noisy(sel_btn), .clean(cln_selBtn));
	debounce lft_button (.reset(reset), .clk(sysClk), .noisy(lft_btn), .clean(cln_lftBtn));
	debounce rht_button (.reset(reset), .clk(sysClk), .noisy(rht_btn), .clean(cln_rhtBtn));

	picoblaze CPU (
		.port_id 			(pb_port_id),
		.read_strobe 		(pb_read_strobe),
		.in_port 			(pb_in_port),
		.write_strobe 		(pb_write_strobe),
		.out_port			(pb_out_port),
		.interrupt			(pb_interrupt),
		.interrupt_ack		(),
		.reset				(pb_reset),
		.clk				(sysClk)
	);	
	
	lcd_fsm LCD (
		.mov_up				(cln_upBtn), 
		.mov_dwn			(cln_dwnBtn), 
		.sel				(cln_selBtn),
		.vol_dwn			(cln_lftBtn),
		.vol_up				(cln_rhtBtn),
		.wrt_req			(fsm_wrt_req), 
		.wrt_ack			(lcd_wrt_ack), 
		.lcd_state			(lcd_nxt_state),
        .vol_level          (),
		.clk				(sysClk), 
		.reset				(pb_reset)
	);
	
	
    always@(posedge pb_read_strobe)
    begin
        case(pb_port_id)
            8'h04:	pb_in_port <= {7'b0000000,fsm_wrt_req};
            8'h06:	pb_in_port <= lcd_nxt_state;
            default: pb_in_port <= 8'h00;
        endcase
    end
	
    always@(posedge pb_write_strobe)
    begin
        case(pb_port_id)
            8'h00: lcd_enb <= pb_out_port[0];
            8'h01: lcd_rs <= pb_out_port[0];
            8'h02: lcd_rw <= pb_out_port[0];
            8'h03: lcd_data <= pb_out_port[3:0];
            8'h05: lcd_wrt_ack <= pb_out_port[0];
        endcase
    end

endmodule



// TEST MODULE  
module clock_33MHz (clk, reset, clk_out);

    input clk, reset;
    output reg clk_out;    
    localparam constant = 3;   
    reg[1:0] counter;
    
    always@(posedge clk or posedge reset) begin
        if(reset) 
            counter <= 2'b00;
        else if (counter == constant - 1) 
            counter <= 2'b00;
        else 
            counter <= counter + 1;
    end
    
    always@(posedge clk or posedge reset) begin
        if(reset) 
            clk_out <= 1'b0;
        else if (counter == constant - 1) 
            clk_out <= ~clk_out;
        else 
            clk_out <= clk_out;
    end
    
endmodule
// TEST MODULE


// module adapted from "debounce.v" created/provided by Massachusetts Institute of Technology
// http://web.mit.edu/6.111/www/f2005/code/jtag2mem_6111/debounce.v.html 
module debounce (reset, clk, noisy, clean);

	// inputs / outputs
	input reset, clk, noisy; // active-low reset for FPGA board
	output reg clean;
	
	// registers
	reg [19:0] count;
	reg tmp;
	
	// parameters
	parameter MAX_COUNT = 1000000; // .01 sec with 100 MHz clock (clock frequency x .01 sec)

	// sequential logic
	always @(posedge clk)
		if (reset == 0) begin 
			tmp <= noisy; 
			clean <= noisy; 
			count <= 1'b0; 
		end else if (noisy != tmp) begin 
			tmp <= noisy; 
			count <= 1'b0; 
		end else if (count == MAX_COUNT) 
			clean <= tmp;
		else 
			count <= count + 1'b1;
			
endmodule
	 