module Decoder(
  input clk, reset, Start,
  input [63:0] Ciphertext,
  input [79:0] KEY0,
  output reg done,
  output  [63:0] Plaintext);
  
  reg [1:0]state;
  parameter IDLE=2'b00;
  parameter Key25=2'b01;
  parameter Round=2'b10; 
  parameter Round0=2'b11; 

  
  // Key 25:
  reg [79:0] key; 
  wire [79:0] key_reg;
  reg [79:0] key_25;
  reg [4:0] counter; 
  reg [4:0] counter_25;
  Key_Generator keyreg(key,counter_25,key_reg);
  
  // Round block:
  reg [79:0] round_key; 
  reg [63:0] state_out; 
  wire [63:0] state_in;
  Round_dec round_dec(round_key,state_out,state_in);
  assign Plaintext = done ? state_in : 64'hFFFF_FFFF_FFFF_FFFF;

  
  // Keygen_decoder:
  reg key25_finish;
  reg [79:0] key_dec; 
  wire [79:0] key_reg_dec;
  Key_Gen_dec keygen_dec(key_dec,counter,key_reg_dec);
  
  always @(posedge clk) begin
    if(reset == 0) begin
        state <= IDLE;
        done <= 0;
    end else begin       
      case(state) 
        IDLE: begin
          if(Start == 1) begin
            counter_25 <= 5'd0;
            key <= KEY0; 
            state <= Key25;
            done <= 0;
          end
        end
        Key25: begin
          if (counter_25 < 5'd24) begin
            counter_25 <= counter_25 + 1;
            key <= key_reg;
            key25_finish <= 0;
          end else if (counter_25 == 5'd24) begin
            key_25 <= key_reg;
            state <= Round; 
            counter <= 5'd24;
            key_dec <= key_reg;
          end
        end
        Round: begin
          if (counter == 5'd24) begin
            key_dec <= key_reg_dec;
            round_key <= key_reg_dec;
            state_out <= Ciphertext ^ key_25[63:0];
            counter <= counter -1; 
          end else if(counter > 5'd0) begin
            key_dec <= key_reg_dec;
            state_out <= state_in;
            round_key <= key_reg_dec;
            counter <= counter -1;
          end else if (counter == 5'd0) begin
            state_out <= state_in;
            round_key <= key_reg_dec;
            state <= Round0;
            done <= 1;
          end
        end 
        Round0: begin
          state <= IDLE;  
        end
      endcase 
    end
  end

endmodule


///// KEY GENERATOR DECODER:
module Key_Gen_dec(
    input [79:0] KEY,
    input [4:0] RC,
    output [79:0] key_register);
    wire [79:0] keywr; wire [3:0] key1; wire [4:0] key2;
    
    assign key2 = KEY[63:59] ^ RC;
    S_Box_dec lsb(KEY[3:0],key1);
    assign keywr = {KEY[79:64],key2,KEY[58:4],key1};
    assign key_register = {keywr[12:0],keywr[79:13]};
    
endmodule
