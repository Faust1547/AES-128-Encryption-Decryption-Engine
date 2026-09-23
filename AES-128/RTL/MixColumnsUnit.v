`timescale 1ns / 1ps
module MixColumnUnit(
    input  wire [31:0] Col_in,   // A0,A1,A2,A3
    output wire [31:0] Col_out   // b0,b1,b2,b3
);
wire [7:0] A0 = Col_in[31:24];
wire [7:0] A1 = Col_in[23:16];
wire [7:0] A2 = Col_in[15: 8];
wire [7:0] A3 = Col_in[ 7: 0];

function  [7:0] X02;
	input [7:0] a;
	reg   [7:0] a_shifted;
	begin
	    a_shifted = a << 1;
    	X02 = (a[7] == 1) ? (a_shifted^8'b00011011) : a_shifted;
	end
endfunction

function  [7:0] X03;
	input [7:0] a;
	reg   [7:0] a_shifted, a_X02;
	begin 
    	a_shifted = a << 1;
    	a_X02 = (a[7] == 1) ? (a_shifted^8'b00011011) : a_shifted;
    	X03   = a_X02 ^ a;
	end
endfunction

assign Col_out = {
		X02(A0) ^ X03(A1) ^ A2 ^ A3,
        A0 ^ X02(A1) ^ X03(A2) ^ A3,
        A0 ^ A1 ^ X02(A2) ^ X03(A3),
        X03(A0) ^ A1 ^ A2 ^ X02(A3)
    };
endmodule
