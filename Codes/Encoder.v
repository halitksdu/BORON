module Encoder(
  input clk, reset, Start,
  input [63:0] Plaintext,
  input [79:0] KEY0,
  output reg done,
  output reg [63:0] Ciphertext  );
    
  parameter IDLE = 2'b00;
  parameter LOAD = 2'b01; 
  parameter Round = 2'b10;
  parameter Round25 = 2'b11;
  reg [1:0] state;    
  // Anahtar:
  reg [4:0] counter;
  reg [79:0] key; wire [79:0]key_reg; 
  Key_Generator keygen(key,counter,key_reg);
  
  // Round: 
  reg [63:0] stateara_in; wire [63:0] stateara_out;
  Round_enc  round_enc(key,stateara_in,stateara_out);
  
  always @(posedge clk) begin
    if(reset == 0) begin
      state <= IDLE;
      counter <= 5'd0; // 24 bit eleman alýcaz
    
    end else begin
      case (state) 
        IDLE: begin 
          done <= 0;
          if (Start == 1) begin
            state <= LOAD;
            counter <= 5'd0;
          end
        end    
        LOAD: begin
          key <= KEY0; 
          stateara_in <= Plaintext;
          state <= Round;
        end
        Round: begin 
          if (counter < 5'd24) begin
            counter <= counter +1;
            key <= key_reg; 
            stateara_in <= stateara_out;
          end else if (counter == 5'd24) begin
            state <= Round25;
            Ciphertext <= stateara_out ^ key_reg[63:0];
            done <= 1;
            state <= IDLE;
          end
        end     
      endcase
    end
  end
  
endmodule


//// KEYGEN ENCODER:
module Key_Generator(
    input [79:0] KEY,
    input [4:0] RC, 
    output [79:0] Key_Register );
    wire [79:0] keywr; wire [3:0] key1; wire [4:0] key2;

    assign keywr = {KEY[66:0],KEY[79:67]};
    S_Box lsb(keywr[3:0],key1);        
    assign key2 = (RC ^ keywr[63:59]);
    assign Key_Register = {keywr[79:64],key2,keywr[58:4],key1};
    
endmodule
