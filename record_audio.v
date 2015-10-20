`timescale 1ns / 1ps

module record_audio(
    input clk,
    input reset,
    input enb,
    input audio_rdy,
    input set_track,
    input[2:0] track_id,
    output reg write_enb,
    output reg mem_full,
    output reg[25:0] mem_addr
    );

// registers
reg[25:0] max_addr;

// state encoding
parameter write =           1'b0;
parameter write_disable =   1'b1;

// state registers
reg state = write;

// function
always@ (posedge clk) begin
    if (reset) begin
    
        write_enb <= 1'b0;
        mem_full <= 1'b0;
        max_addr <= 0;
        mem_addr <= 0;
        state <= write;
        
    end else if (enb) begin
        
        if (set_track) begin
            case (track_id)
                3'b000: begin
                    mem_addr <= 0;
                    max_addr <= 26843544;
                end
                3'b001: begin
                    mem_addr <= 26843545;
                    max_addr <= 53687089;
                end
                3'b010: begin
                    mem_addr <= 53687090;
                    max_addr <= 80530634;
                end
                3'b011: begin
                    mem_addr <= 80530635;
                    max_addr <= 107374179;
                end
                3'b100: begin
                    mem_addr <= 107374180;
                    max_addr <= 134217725;
                end
            endcase
        end else if (mem_addr < max_addr) begin
            mem_full <= 1'b0;
            case (state)
            
                write: begin
                    if (audio_rdy) begin
                        write_enb <= 1'b1;
                        mem_addr <= mem_addr + 1'b1;
                        state <= write_disable;
                    end
                end
                
                write_disable: begin
                    write_enb <= 1'b0;
                    state <= write;
                end
                
            endcase
        end else if (mem_addr == max_addr) begin
            mem_full <= 1'b1;   
        end
        
    end else begin
        write_enb <= 1'b0;
        mem_full <= 1'b0;
        max_addr <= 0;
        mem_addr <= 0;
        state <= write;
    end
end

endmodule
