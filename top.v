module top(
    input Start, clk, reset,
    input [63:0] state_in, 
    input [79:0] KEY0,
    output [63:0] state_out, 
    output done );
    
    // Encoder:
    wire [63:0] state_out_enc; 
    wire done_enc;
    Encoder enc(clk, reset, Start, state_in, KEY0, done_enc, state_out_enc);
    // Decoder: 
    Decoder dec(clk, reset, done_enc, state_out_enc, KEY0, done, state_out);
    
    assign state_in_enc = state_in;
    
    
endmodule