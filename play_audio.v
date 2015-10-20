`timescale 1ns / 1ps

module play_audio(
    input clk,
    input reset,
    input enb,
    input audio_rdy,
    input data_present,
    input set_track,
    input[2:0] track_id,
    input[25:0] end_addr,
    output reg read_req,
    output reg read_ack,
    output reg[25:0] mem_addr
    );

// state encoding
parameter request =         1'b0;
parameter read =            1'b1;

// state registers
reg state = request;

// function
always@ (posedge clk) begin
    if (reset) begin
        
        read_req <= 1'b0;
        read_ack <= 1'b0;
        mem_addr <= 0;
        state <= request;
        
    end else if (enb) begin
        
        if (set_track) begin
            case (track_id)
                3'b000: begin
                    mem_addr <= 0;
                end
                3'b001: begin
                    mem_addr <= 26843545;
                end
                3'b010: begin
                    mem_addr <= 53687090;
                end
                3'b011: begin
                    mem_addr <= 80530635;
                end
                3'b100: begin
                    mem_addr <= 107374180;
                end
            endcase
        end else if (mem_addr < end_addr) begin
            case (state)
        
                request: begin
                    read_ack <= 1'b0;
                    if (audio_rdy) begin
                        read_req <= 1'b1;
                        state <= read;
                    end
                end
                
                read: begin
                    read_req <= 1'b0;
                    if (data_present) begin
                        read_ack <= 1'b1;
                        mem_addr <= mem_addr + 1'b1;
                        state <= request;
                    end
                end

            endcase
        end
        
    end else begin
        read_req <= 1'b0;
        read_ack <= 1'b0;
        mem_addr <= 0;
        state <= request;
    end
end

endmodule
