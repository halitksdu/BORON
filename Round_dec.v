module Round_dec(
    input [79:0] round_key,
    input [63:0] state_out,
    output [63:0] state_in);
    
    wire [63:0] S2,S1;
    Permutation_Layer_dec f3(state_out,S2); 
    S_Box_Layer_dec       f2(S2,S1);
    Add_round_key         f1(S1,round_key[63:0],state_in);
endmodule

///// PERMUTATION LAYER:

module Permutation_Layer_dec(
    input [63:0] state_out,
    output [63:0] state_in  );
   
    wire [63:0] S1,S2;
    XOR_Operation_dec      f3(state_out,S2);
    Round_Permutation_dec  f2(S2,S1);
    Block_Shuffle          f1(S1,state_in);
    
endmodule


module XOR_Operation_dec(
    input [63:0] W_x,
    output [63:0] X );
    
    assign X[63:48] = (W_x[63:48]^W_x[47:32]);
    assign X[47:32] = (W_x[47:32]^((W_x[63:48]^W_x[47:32])^(W_x[63:48]^W_x[47:32]^W_x[31:16])^W_x[15:0])); 
    assign X[31:16] = (W_x[63:48]^W_x[47:32]^W_x[31:16]);
    assign X[15:0]  = ((W_x[63:48]^W_x[47:32])^(W_x[63:48]^W_x[47:32]^W_x[31:16])^W_x[15:0]); 

endmodule


module Round_Permutation_dec(
    input [63:0] r_j,
    output reg [63:0] j  );
        
    always @* begin
        j[63:48] = {r_j[56:48],r_j[63:57]};
        j[47:32] = {r_j[38:32],r_j[47:39]};
        j[31:16] = {r_j[19:16],r_j[31:20]};
        j[15:0]  = {r_j[0], r_j[15:1]};
    end 
endmodule


///// S_BOX LAYER DECODER:
module S_Box_Layer_dec(
    input [63:0] S_x,
    output [63:0] X);
    
    genvar i;
    generate for(i=0; i<16; i=i+1)  begin S_Box_dec f(S_x[(4*i+3) : (4*i)], X[(4*i+3) : (4*i)]);  end endgenerate
endmodule

module S_Box_dec(
    input [3:0] S_a,
    output reg [3:0] A); 
    always @* begin
        case(S_a)
            4'h0: A= 4'ha;
            4'h1: A= 4'h3;    
            4'h2: A= 4'h9;
            4'h3: A= 4'he;
            4'h4: A= 4'h1;    
            4'h5: A= 4'hd;
            4'h6: A= 4'hf;
            4'h7: A= 4'h4;    
            4'h8: A= 4'hc;
            4'h9: A= 4'h5;
            4'ha: A= 4'h7;    
            4'hb: A= 4'h2;
            4'hc: A= 4'h6;    
            4'hd: A= 4'h8;
            4'he: A= 4'h0;    
            4'hf: A= 4'hb;
        endcase
    end
    
endmodule
