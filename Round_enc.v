module Round_enc(
    input [79:0] round_key,
    input [63:0] state_in,
    output [63:0] state_out );
    
    
    wire [63:0] S1,S2;
    Add_round_key     f1(state_in,round_key[63:0],S1);  //ilk þifre 0
    S_Box_Layer       f2(S1,S2);
    Permutation_Layer f3(S2,state_out);
    
endmodule


///// ADD ROUND KEY:

module Add_round_key(
input 	[63:0] 	State_in,
input 	[63:0] 	Round_key,
output	[63:0] 	State_out
);

	assign State_out = State_in ^ Round_key;

endmodule

///// S BOX LAYER:

module S_Box_Layer(
input 	[63:0] X,
output 	[63:0] S_x
);

	genvar i;
	generate for(i=0; i<16; i=i+1)  begin S_Box f(X[(4*i+3) : (4*i)], S_x[(4*i+3) : (4*i)]);  end endgenerate
	
endmodule


module S_Box(
input 			[3:0]	data_i,
output reg 	[3:0]	dataOut
);

	always @(*) begin
		case(data_i)
			4'h0:dataOut=4'hE;
			4'h1:dataOut=4'h4;
			4'h2:dataOut=4'hB;
			4'h3:dataOut=4'h1;
			4'h4:dataOut=4'h7;
			4'h5:dataOut=4'h9;
			4'h6:dataOut=4'hC;
			4'h7:dataOut=4'hA;
			4'h8:dataOut=4'hD;
			4'h9:dataOut=4'h2;
			4'hA:dataOut=4'h0;
			4'hB:dataOut=4'hF;
			4'hC:dataOut=4'h8;
			4'hD:dataOut=4'h5;
			4'hE:dataOut=4'h3;
			4'hF:dataOut=4'h6;
			default:dataOut=4'hX;
		endcase
	end

endmodule

///// PERMUTATION LAYER:

module Permutation_Layer(
    input [63:0] state_in,
    output [63:0] state_out);
    
    wire [63:0] S1, S2;
    Block_Shuffle     bs(state_in,S1);
    Round_Permutation rp(S1,S2);
    XOR_Operation     xr(S2,state_out);
    
endmodule


module Block_Shuffle(
    input [63:0] j,
    output [63:0] B_j );
    genvar i;
    generate for(i=0; i<4; i=i+1) begin  Block_S f(j[(16*i+15) : (16*i)], B_j[(16*i+15) : (16*i)]);  end endgenerate
endmodule

module Block_S(
    input [15:0] a,
    output reg [15:0] B_a);
    always @* begin
        B_a[3:0]  = a[11:8];
        B_a[7:4]  = a[15:12];
        B_a[11:8] = a[3:0];
        B_a[15:12]= a[7:4];
    end
endmodule


module Round_Permutation(
    input [63:0] j,
    output reg [63:0] r_j  );
    
    always @* begin
        r_j[63:48] = {j[54:48],j[63:55]};
        r_j[47:32] = {j[40:32],j[47:41]};
        r_j[31:16] = {j[27:16],j[31:28]};
        r_j[15:0]  = {j[14:0],j[15]};
    end
endmodule


module XOR_Operation(
    input [63:0] X,
    output reg [63:0] W_x );
    
    always @* begin
        W_x[63:48] = (X[63:48]^X[47:32]^X[15:0]);
        W_x[47:32] = (X[47:32]^X[15:0]);
        W_x[31:16] = (X[63:48]^X[31:16]);
        W_x[15:0]  = (X[63:48]^X[31:16]^X[15:0]);
    end
endmodule