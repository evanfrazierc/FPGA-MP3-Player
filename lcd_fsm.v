`timescale 1ns / 1ps

// FSM for LCD
// Display appropriate menu given user input

module lcd_fsm(
    input clk,
    input reset,
    input play_sw,
    input mov_up, 
    input mov_dwn, 
    input sel, 
    input vol_dwn, 
    input vol_up,
    input wrt_ack,
    input audio_rdy,
    input data_present_bro,
    input ram_rdy,
    output reg wrt_req,
    output reg write_enb,
    output reg read_req,
    output reg read_ack,
    output reg[7:0] lcd_state, 
    output reg[4:0] vol_level,
    output reg[25:0] addr,
    output reg[7:0] leds
    );
    
    // track end address registers
    reg[25:0] tr1_end = 0;
    reg[25:0] tr2_end = 0;
    reg[25:0] tr3_end = 0;
    reg[25:0] tr4_end = 0;
    reg[25:0] tr5_end = 0;
     
	// state encoding
	parameter send_request =	    6'b000000;
	parameter get_ack =			    6'b000001;
	parameter hello =			    6'b000010;
	parameter play = 			    6'b000011;
	parameter record = 			    6'b000100;
	parameter delete =			    6'b000101;
	parameter delete_all = 		    6'b000110;
	parameter volume =			    6'b000111;
	parameter vol_lvl_1 =		    6'b001000;
	parameter vol_lvl_2 =		    6'b001001;
	parameter vol_lvl_3 =		    6'b001010;
    parameter memfull =             6'b001011;
    parameter trk_1_play =          6'b001100;
    parameter trk_2_play =          6'b001101;
    parameter trk_3_play =          6'b001110;
    parameter trk_4_play =          6'b001111;
    parameter trk_5_play =          6'b010000;
    parameter trk_1_del =           6'b010001;
    parameter trk_2_del =           6'b010010;
    parameter trk_3_del =           6'b010011;
    parameter trk_4_del =           6'b010100;
    parameter trk_5_del =           6'b010101;
    parameter back_play =           6'b010110;
    parameter back_del =            6'b010111;
    parameter write =               6'b011000;
    parameter write_disable =       6'b011001;
    parameter tr1_read_request =    6'b011010;
    parameter tr1_read_data =       6'b011011;
    parameter tr2_read_request =    6'b011100;
    parameter tr2_read_data =       6'b011101;
    parameter tr3_read_request =    6'b011110;
    parameter tr3_read_data =       6'b011111;
    parameter tr4_read_request =    6'b100000;
    parameter tr4_read_data =       6'b100001;
    parameter tr5_read_request =    6'b100010;
    parameter tr5_read_data =       6'b100011;
    parameter trk_1_rec =           6'b100100;
    parameter trk_2_rec =           6'b100101;
    parameter trk_3_rec =           6'b100110;
    parameter trk_4_rec =           6'b100111;
    parameter trk_5_rec =           6'b101000;
    parameter tr1_write =           6'b101001;
    parameter tr1_write_disable =   6'b101010;
    parameter tr2_write =           6'b101011;
    parameter tr2_write_disable =   6'b101100;
    parameter tr3_write =           6'b101101;
    parameter tr3_write_disable =   6'b101110;
    parameter tr4_write =           6'b101111;
    parameter tr4_write_disable =   6'b110000;
    parameter tr5_write =           6'b110001;
    parameter tr5_write_disable =   6'b110010;
    parameter back_rec =            6'b110011;
	
	// state registers
	reg[5:0] state = hello;
	reg[5:0] return_state = play;

	// next state
	always@ (posedge clk) begin
		if (reset) begin
		
			state <= hello;
			return_state <= play;
            lcd_state <= 8'h00;
            
			wrt_req <= 0;
			vol_level <= 0;
            write_enb <= 0;
            read_req <= 0;
            read_ack <= 0;
            addr <= 0;
            leds <= 0;
            
		end else begin
			case (state)
			
				// empty state for welcome message
				hello: begin
					if (sel && ram_rdy) begin	
                    
						state <= send_request;
						return_state <= play;
						lcd_state <= 8'h00;
                        
                        vol_level <= 0;
                        wrt_req <= 0;
                        write_enb <= 0;
                        read_req <= 0;
                        read_ack <= 0;
                        addr <= 0;
                        leds <= 0;
                        
					end
				end
			
			
				play: begin
					//lcd_state 8'h00                     
					if (!mov_up && mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= record;
						lcd_state <= 8'h01;
						
					end else if (sel) begin
                    
                        state <= send_request;
                        return_state <= trk_1_play;
                        lcd_state <= 8'h09;
                    
                        addr <= 0;
                        write_enb <= 0;
                        read_req <= 1'b0;
                        read_ack <= 1'b0;
                        leds <= 0; 
                        
					end
				end
               
               /////////////////////////////////////////////////////////////////////////////////////////// 
				record: begin
					//lcd_state 8'h01
					if (mov_up && !mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= play;
						lcd_state <= 8'h00;
						
					end else if (!mov_up && mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= delete;
						lcd_state <= 8'h02;
						
					end else if (sel) begin
                        
                        state <= send_request;
                        return_state <= trk_1_rec;
                        lcd_state <= 8'h09;
                        
					end
				end	              
                
                /////////////////////////////////////////////////////////////////////////////////////////// 
                
				delete: begin
					//lcd state 8'h02
					if (mov_up && !mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= record;
						lcd_state <= 8'h01;
						
					end else if (!mov_up && mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= delete_all;
						lcd_state <= 8'h03;
						
					end else if (sel) begin
                        
                        state <= send_request;
                        return_state <= trk_1_del;
                        lcd_state <= 8'h09;
                    
					end
				end
				
				
				delete_all: begin
					//lcd state 8'h03
					if (mov_up && !mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= delete;
						lcd_state <= 8'h02;
						
					end else if (!mov_up && mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= volume;
						lcd_state <= 8'h04;
						
					end else if (sel) begin
                    
                        tr1_end <= 0;
                        tr2_end <= 0;
                        tr3_end <= 0;
                        tr4_end <= 0;
                        tr5_end <= 0;
                    
					end
				end
				
				
				volume: begin
					//lcd state 8'h04
					if (mov_up && !mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= delete_all;
						lcd_state <= 8'h03;
						
					end else if (sel) begin
					
						state <= send_request;
						
						case (vol_level)
							5'b00000: begin
								return_state <= vol_lvl_1;
								lcd_state <= 8'h05;
							end
							5'b00110: begin
								return_state <= vol_lvl_2;
								lcd_state <= 8'h06;
							end
							5'b01100: begin
								return_state <= vol_lvl_3;
								lcd_state <= 8'h07;
							end
							default: begin
								return_state <= vol_lvl_1;
								lcd_state <= 8'h05;
							end
						endcase	
						
					end
				end
				
				
				vol_lvl_1: begin
					//lcd state 8'h05
					if (vol_up && !sel) begin
					
						state <= send_request;
						return_state <= vol_lvl_2;
						lcd_state <= 8'h06;
						
					end else if (sel) begin
					
						state <= send_request;
						return_state <= volume;
						lcd_state <= 8'h04;
						vol_level <= 5'b00000;
						
					end
				end
				
				
				vol_lvl_2: begin
					//lcd state 8'h06
					if (vol_dwn && !vol_up && !sel) begin
					
						state <= send_request;
						return_state <= vol_lvl_1;
						lcd_state <= 8'h05;
						
					end else if (!vol_dwn && vol_up && !sel) begin
					
						state <= send_request;
						return_state <= vol_lvl_3;
						lcd_state <= 8'h07;
						
					end else if (sel) begin
					
						state <= send_request;
						return_state <= volume;
						lcd_state <= 8'h04;
						vol_level <= 5'b00110;
						
					end
				end
				
				
				vol_lvl_3: begin
					//lcd state 8'h07
					if (vol_dwn && !sel) begin
					
						state <= send_request;
						return_state <= vol_lvl_2;
						lcd_state <= 8'h06;
						
					end else if (sel) begin
					
						state <= send_request;
						return_state <= volume;
						lcd_state <= 8'h04;
						vol_level <= 5'b01100;
						
					end
				end
				
                ///////////////////////////////////////////////////////////////////////////////////////////
                ///////////////////////////////////////////////////////////////////////////////////////////
                ///////////////////////////////////////////////////////////////////////////////////////////
               
                trk_1_play: begin
                   //lcd state 8'h09 
                   if (!mov_up && mov_dwn) begin
					
						state <= send_request;
						return_state <= trk_2_play;
						lcd_state <= 8'h0A;
						
					end else if (play_sw) begin
                    
                        addr <= 0;
                        state <= tr1_read_request;
                        
					end
                end

                
                tr1_read_request: begin
                
                    write_enb <= 0;
                    read_ack <= 1'b0;
                    
                    if (audio_rdy && (addr < tr1_end)) begin
                    
                        read_req <= 1'b1;
                        state <= tr1_read_data;
                        
                    end else if (addr == tr1_end || !play_sw) begin
                    
                        state <= send_request;
                        return_state <= trk_1_play;
                        lcd_state <= 8'h09;
                    
                    end
                    
                end
                
                
                tr1_read_data: begin
                
                    write_enb <= 0;
                    read_req <= 1'b0;
                    
                    if (data_present_bro && play_sw) begin
                    
                        read_ack <= 1'b1;
                        addr <= addr + 1'b1;
                        leds <= leds + 1'b1;
                        state <= tr1_read_request;
                        
                    end else if (!play_sw) begin
                    
                        state <= send_request;
                        return_state <= trk_1_play;
                        lcd_state <= 8'h09;
                        
                    end
                    
                end
                /////////////////////////////////////////////////////////////////////////////////////////// 
                
               trk_2_play: begin
                    //lcd state 8'h0A
                   if (mov_up && !mov_dwn) begin
					
						state <= send_request;
						return_state <= trk_1_play;
						lcd_state <= 8'h09;
						
					end else if (!mov_up && mov_dwn) begin
					
						state <= send_request;
						return_state <= trk_3_play;
						lcd_state <= 8'h0B;
						
					end else if (play_sw) begin
                    
                        addr <= 8259553;
                        state <= tr2_read_request; 
                        
					end
               end
               
               
               tr2_read_request: begin
                
                    write_enb <= 0;
                    read_ack <= 1'b0;
                    
                    if (audio_rdy && (addr < tr2_end)) begin
                    
                        read_req <= 1'b1;
                        state <= tr2_read_data;
                        
                    end else if (addr == tr2_end || !play_sw) begin
                    
                        state <= send_request;
                        return_state <= trk_2_play;
                        lcd_state <= 8'h0A;
                    
                    end
                    
                end
                
                
                tr2_read_data: begin
                
                    write_enb <= 0;
                    read_req <= 1'b0;
                    
                    if (data_present_bro && play_sw) begin
                    
                        read_ack <= 1'b1;
                        addr <= addr + 1'b1;
                        leds <= leds + 1'b1;
                        state <= tr2_read_request;
                        
                    end else if (!play_sw) begin
                    
                        state <= send_request;
                        return_state <= trk_2_play;
                        lcd_state <= 8'h0A;
                        
                    end
                    
                end
               /////////////////////////////////////////////////////////////////////////////////////////// 
               
               trk_3_play: begin
                    //lcd state 8'h0B
                   if (mov_up && !mov_dwn) begin
					
						state <= send_request;
						return_state <= trk_2_play;
						lcd_state <= 8'h0A;
						
					end else if (!mov_up && mov_dwn) begin
					
						state <= send_request;
						return_state <= trk_4_play;
						lcd_state <= 8'h0C;
						
					end else if (play_sw) begin
                    
                        addr <= 16519105;
                        state <= tr3_read_request;
                        
					end
               end
               
               
               tr3_read_request: begin
                
                    write_enb <= 0;
                    read_ack <= 1'b0;
                    
                    if (audio_rdy && (addr < tr3_end)) begin
                    
                        read_req <= 1'b1;
                        state <= tr3_read_data;
                        
                    end else if (addr == tr3_end || !play_sw) begin
                    
                        state <= send_request;
                        return_state <= trk_3_play;
                        lcd_state <= 8'h0B;
                    
                    end
                    
                end
                
                
                tr3_read_data: begin
                
                    write_enb <= 0;
                    read_req <= 1'b0;
                    
                    if (data_present_bro && play_sw) begin
                    
                        read_ack <= 1'b1;
                        addr <= addr + 1'b1;
                        leds <= leds + 1'b1;
                        state <= tr3_read_request;
                        
                    end else if (!play_sw) begin
                    
                        state <= send_request;
                        return_state <= trk_3_play;
                        lcd_state <= 8'h0B;
                        
                    end
                    
                end
               ///////////////////////////////////////////////////////////////////////////////////////////
               
               trk_4_play: begin
                    //lcd state 8'h0C
                   if (mov_up && !mov_dwn) begin
					
						state <= send_request;
						return_state <= trk_3_play;
						lcd_state <= 8'h0B;
                        
					end else if (!mov_up && mov_dwn) begin
					
						state <= send_request;
						return_state <= trk_5_play;
						lcd_state <= 8'h0D;
						
					end else if (play_sw) begin
                    
                        addr <= 24778657;
                        state <= tr4_read_request; 
                        
					end
               end
               
               
               tr4_read_request: begin
                
                    write_enb <= 0;
                    read_ack <= 1'b0;
                    
                    if (audio_rdy && (addr < tr4_end)) begin
                    
                        read_req <= 1'b1;
                        state <= tr4_read_data;
                        
                    end else if (addr == tr4_end || !play_sw) begin
                    
                        state <= send_request;
                        return_state <= trk_4_play;
                        lcd_state <= 8'h0C;
                    
                    end
                    
                end
                
                
                tr4_read_data: begin
                
                    write_enb <= 0;
                    read_req <= 1'b0;
                    
                    if (data_present_bro && play_sw) begin
                    
                        read_ack <= 1'b1;
                        addr <= addr + 1'b1;
                        leds <= leds + 1'b1;
                        state <= tr4_read_request;
                        
                    end else if (!play_sw) begin
                    
                        state <= send_request;
                        return_state <= trk_4_play;
                        lcd_state <= 8'h0C;
                        
                    end
                    
                end
               ///////////////////////////////////////////////////////////////////////////////////////////
               
               trk_5_play: begin
                    //lcd state 8'h0D
                   if (mov_up && !mov_dwn) begin
					
						state <= send_request;
						return_state <= trk_4_play;
						lcd_state <= 8'h0C;
						
					end else if (!mov_up && mov_dwn) begin
					
						state <= send_request;
						return_state <= back_play;
						lcd_state <= 8'h0E;
                        
					end else if (play_sw) begin
                    
                        addr <= 33038209;
                        state <= tr5_read_request;
                        
					end
                end
               
               
               tr5_read_request: begin
                
                    write_enb <= 0;
                    read_ack <= 1'b0;
                    
                    if (audio_rdy && (addr < tr5_end)) begin
                    
                        read_req <= 1'b1;
                        state <= tr5_read_data;
                        
                    end else if (addr == tr5_end || !play_sw) begin
                    
                        state <= send_request;
                        return_state <= trk_5_play;
                        lcd_state <= 8'h0D;
                    
                    end
                    
                end
                
                
                tr5_read_data: begin
                
                    write_enb <= 0;
                    read_req <= 1'b0;
                    
                    if (data_present_bro && play_sw) begin
                    
                        read_ack <= 1'b1;
                        addr <= addr + 1'b1;
                        leds <= leds + 1'b1;
                        state <= tr5_read_request;
                        
                    end else if (!play_sw) begin
                    
                        state <= send_request;
                        return_state <= trk_5_play;
                        lcd_state <= 8'h0D;
                        
                    end
                    
                end
               ///////////////////////////////////////////////////////////////////////////////////////////
               
               back_play: begin
                    //lcd state 8'h0E
                    if (mov_up && !mov_dwn && !sel) begin
                    
                        state <= send_request;
                        return_state <= trk_5_play;
                        lcd_state <= 8'h0D;
                        
                    end else if (sel) begin
						
                        state <= send_request;
                        return_state <= play;
                        lcd_state <= 8'h00;
                        
					end
               end
               
               ///////////////////////////////////////////////////////////////////////////////////////////
               ///////////////////////////////////////////////////////////////////////////////////////////
               ///////////////////////////////////////////////////////////////////////////////////////////
               
               memfull: begin
                    // lcd state 8'h0F
                    if (sel) begin
                        
                        state <= send_request;
                        return_state <= play;
                        lcd_state <= 8'h00;
                        
                    end
                    
               end
               
               
               trk_1_rec: begin
                    //lcd state 8'h09
                   if (!mov_up && mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= trk_2_rec;
						lcd_state <= 8'h0A;
						
					end else if (sel) begin
                    
                        state <= send_request;
                        lcd_state <= 8'h08;
                        return_state <= tr1_write;
                        
                        addr <= 0;
                        
                        write_enb <= 0;
                        read_req <= 1'b0;
                        read_ack <= 1'b0;
                        
					end
               end
 
 
                tr1_write: begin
                
                    if (sel) begin
                    
                        state <= send_request;
                        return_state <= record;
                        lcd_state <= 8'h01;
                        
                        tr1_end <= addr;
                     
                    end else if (addr == 8259552) begin
    
                        state <= send_request;
                        return_state <= memfull;
                        lcd_state <= 8'h0F;
                        
                        tr1_end <= addr;
                    
                    end else if (audio_rdy && (addr < 8259552)) begin
                    
                        write_enb <= 1'b1;
                        addr <= addr + 1'b1;
                        leds <= leds + 1'b1;
                        state <= tr1_write_disable;
                        
                    end
                end
                
                
                tr1_write_disable: begin
                
                    write_enb <= 1'b0;
                    state <= tr1_write;
                    
                end
               
               ///////////////////////////////////////////////////////////////////////////////////////////
               
               trk_2_rec: begin
                    //lcd state 8'h0A
                   if (mov_up && !mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= trk_1_rec;
						lcd_state <= 8'h09;
						
					end else if (!mov_up && mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= trk_3_rec;
						lcd_state <= 8'h0B;
						
					end else if (sel) begin
                            
                        state <= send_request;
                        lcd_state <= 8'h08;
                        return_state <= tr2_write;
                        
                        addr <= 8259553;
                        
                        write_enb <= 0;
                        read_req <= 1'b0;
                        read_ack <= 1'b0;
                            
					end
                end
               
               
               tr2_write: begin
                
                    if (sel) begin
                    
                        state <= send_request;
                        return_state <= record;
                        lcd_state <= 8'h01;
                        
                        tr2_end <= addr;
                        
                    end else if (addr == 16519104) begin

                        state <= send_request;
                        return_state <= memfull;
                        lcd_state <= 8'h0F;
                        
                        tr2_end <= addr;   
                            
                    end else if (audio_rdy && (addr < 16519104)) begin
                    
                        write_enb <= 1'b1;
                        addr <= addr + 1'b1;
                        leds <= leds + 1'b1;
                        state <= tr2_write_disable;
                        
                    end
                end
                
                
                tr2_write_disable: begin
                
                    write_enb <= 1'b0;
                    state <= tr2_write;
                    
                end
               
               ///////////////////////////////////////////////////////////////////////////////////////////
               
               trk_3_rec: begin
                    //lcd state 8'h0B
                   if (mov_up && !mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= trk_2_rec;
						lcd_state <= 8'h0A;
						
					end else if (!mov_up && mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= trk_4_rec;
						lcd_state <= 8'h0C;
						
					end else if (sel) begin
                         
                        state <= send_request;
                        lcd_state <= 8'h08;
                        return_state <= tr3_write;
                        
                        addr <= 16519105;
                        
                        write_enb <= 0;
                        read_req <= 1'b0;
                        read_ack <= 1'b0;                    
                         
					end
                end
               
               
               tr3_write: begin
                
                    if (sel) begin
                    
                        state <= send_request;
                        return_state <= record;
                        lcd_state <= 8'h01;
                        
                        tr3_end <= addr;
                        
                    end else if (addr == 24778656) begin

                        state <= send_request;
                        return_state <= memfull;
                        lcd_state <= 8'h0F;
                        
                        tr3_end <= addr;
                    
                    end else if (audio_rdy && (addr < 24778656)) begin
                    
                        write_enb <= 1'b1;
                        addr <= addr + 1'b1;
                        leds <= leds + 1'b1;
                        state <= tr3_write_disable;
                        
                    end
                end
                
                
                tr3_write_disable: begin
                
                    write_enb <= 1'b0;
                    state <= tr3_write;
                    
                end
               
               
               ///////////////////////////////////////////////////////////////////////////////////////////
               
               trk_4_rec: begin
                    //lcd state 8'h0C
                   if (mov_up && !mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= trk_3_rec;
						lcd_state <= 8'h0B;
						
					end else if (!mov_up && mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= trk_5_rec;
						lcd_state <= 8'h0D;
						
					end else if (sel) begin
                           
                        state <= send_request;
                        lcd_state <= 8'h08;
                        return_state <= tr4_write;
                        
                        addr <= 24778657;
                        
                        write_enb <= 0;
                        read_req <= 1'b0;
                        read_ack <= 1'b0;
                           
					end
                end
               
               
               tr4_write: begin
                
                    if (sel) begin
                    
                        state <= send_request;
                        return_state <= record;
                        lcd_state <= 8'h01;
                        
                        tr4_end <= addr;
                    
                    end else if (addr == 33038208) begin
                    
                        state <= send_request;
                        return_state <= memfull;
                        lcd_state <= 8'h0F;
                        
                        tr4_end <= addr;
                    
                    end else if (audio_rdy && (addr < 33038208)) begin
                    
                        write_enb <= 1'b1;
                        addr <= addr + 1'b1;
                        leds <= leds + 1'b1;
                        state <= tr4_write_disable;
                        
                    end
                end
                
                
                tr4_write_disable: begin
                
                    write_enb <= 1'b0;
                    state <= tr4_write;
                    
                end
               
               
               ///////////////////////////////////////////////////////////////////////////////////////////
               
               trk_5_rec: begin
                    //lcd state 8'h0D
                   if (mov_up && !mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= trk_4_rec;
						lcd_state <= 8'h0C;
						
					end else if (!mov_up && mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= back_rec;
						lcd_state <= 8'h0E;
						
					end else if (sel) begin
                             
                        state <= send_request;
                        lcd_state <= 8'h08;
                        return_state <= tr5_write;
                        
                        addr <= 33038209;
                        
                        write_enb <= 0;
                        read_req <= 1'b0;
                        read_ack <= 1'b0;
                             
					end
               end
               
               
               tr5_write: begin
                
                    if (sel) begin
                    
                        state <= send_request;
                        return_state <= record;
                        lcd_state <= 8'h01;
                        
                        tr5_end <= addr;
                        
                    end else if (addr == 41297760) begin

                        state <= send_request;
                        return_state <= memfull;
                        lcd_state <= 8'h0F;
                        
                        tr5_end <= addr;
                    
                    end else if (audio_rdy && (addr < 41297760)) begin
                    
                        write_enb <= 1'b1;
                        addr <= addr + 1'b1;
                        leds <= leds + 1'b1;
                        state <= tr5_write_disable;
                        
                    end
                end
                
                
                tr5_write_disable: begin
                
                    write_enb <= 1'b0;
                    state <= tr5_write;
                    
                end
               
               
               ///////////////////////////////////////////////////////////////////////////////////////////
               
               back_rec: begin
                    //lcd state 8'h0E
                    if (mov_up && !mov_dwn && !sel) begin
                    
                        state <= send_request;
                        return_state <= trk_5_rec;
                        lcd_state <= 8'h0D;
                        
                    end else if (sel) begin
						
                        state <= send_request;
                        return_state <= record;
                        lcd_state <= 8'h01;
                        
					end
               end
               
               ///////////////////////////////////////////////////////////////////////////////////////////
                        
               trk_1_del: begin
                    //lcd state 8'h09
                   if (!mov_up && mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= trk_2_del;
						lcd_state <= 8'h0A;
						
					end else if (sel) begin
                    
                        tr1_end <= 0;
                     
					end
                end
               
               
               trk_2_del: begin
                    //lcd state 8'h0A
                   if (mov_up && !mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= trk_1_del;
						lcd_state <= 8'h09;
						
					end else if (!mov_up && mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= trk_3_del;
						lcd_state <= 8'h0B;
						
					end else if (sel) begin
                                
                        tr2_end <= 0;
                                
					end
                end
               
               
               trk_3_del: begin
                    //lcd state 8'h0B
                   if (mov_up && !mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= trk_2_del;
						lcd_state <= 8'h0A;
						
					end else if (!mov_up && mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= trk_4_del;
						lcd_state <= 8'h0C;
						
					end else if (sel) begin
                        
                        tr3_end <= 0;
                        
					end
                end
               
               
               trk_4_del: begin
                    //lcd state 8'h0C
                   if (mov_up && !mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= trk_3_del;
						lcd_state <= 8'h0B;
						
					end else if (!mov_up && mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= trk_5_del;
						lcd_state <= 8'h0D;
						
					end else if (sel) begin
                         
                        tr4_end <= 0;
                         
					end
                end
               
               
               trk_5_del: begin
                    //lcd state 8'h0D
                   if (mov_up && !mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= trk_4_del;
						lcd_state <= 8'h0C;
						
					end else if (!mov_up && mov_dwn && !sel) begin
					
						state <= send_request;
						return_state <= back_del;
						lcd_state <= 8'h0E;
						
					end else if (sel) begin
                                   
                        tr5_end <= 0;
                                   
					end
                end
               
               
               back_del: begin
                    //lcd state 8'h0E
                    if (mov_up && !mov_dwn && !sel) begin
                    
                        state <= send_request;
                        return_state <= trk_5_del;
                        lcd_state <= 8'h0D;
                        
                    end else if (sel) begin
						
                        state <= send_request;
                        return_state <= delete;
                        lcd_state <= 8'h02;
                        
					end
               end
               
               
				send_request: begin
					if (!mov_up && !mov_dwn && !sel && !vol_dwn && !vol_up) begin
						wrt_req <= 1'b1;
						state <= get_ack;
					end
				end
				
				
				get_ack: begin
					if (wrt_ack) begin
						wrt_req <= 1'b0;
						state <= return_state;
					end
				end
				
				
				default: begin
					state <= hello;
					return_state <= play;
					wrt_req <= 1'b0;
					lcd_state <= 8'h00;
                    write_enb <= 0;
                    read_req <= 0;
                    read_ack <= 0;
                    vol_level <= 0;
                    addr <= 0;
                    leds <= 0;
				end
				
				
			endcase
		end
	end
	
endmodule
