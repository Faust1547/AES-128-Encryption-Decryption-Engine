module InvMixColumnsUnit(
    input  wire [31:0] Col_in,   // A0,A1,A2,A3
    output wire [31:0] Col_out   // b0,b1,b2,b3
);
wire [7:0] A0 = Col_in[31:24];
wire [7:0] A1 = Col_in[23:16];
wire [7:0] A2 = Col_in[15: 8];
wire [7:0] A3 = Col_in[ 7: 0];

function [7:0] gm2;
    input [7:0] x;
    begin
        gm2 = {x[6:0],1'b0} ^ (8'h1b & {8{x[7]}});
    end
endfunction

function [7:0] gm4;
    input [7:0] x;
    begin
        gm4 = gm2(gm2(x));
    end
endfunction

function [7:0] gm8;
    input [7:0] x;
    begin
        gm8 = gm2(gm4(x));
    end
endfunction

function [7:0] gm09;
    input [7:0] x;
    begin
        gm09 = gm8(x) ^ x;
    end
endfunction

function [7:0] gm0b;
    input [7:0] x;
    begin
        gm0b = gm8(x) ^ gm2(x) ^ x;
    end
endfunction

function [7:0] gm0d;
    input [7:0] x;
    begin
        gm0d = gm8(x) ^ gm4(x) ^ x;
    end
endfunction

function [7:0] gm0e;
    input [7:0] x;
    begin
        gm0e = gm8(x) ^ gm4(x) ^ gm2(x);
    end
endfunction

assign Col_out = {gm0e(A0) ^ gm0b(A1) ^ gm0d(A2) ^ gm09(A3),
                  gm09(A0) ^ gm0e(A1) ^ gm0b(A2) ^ gm0d(A3),
                  gm0d(A0) ^ gm09(A1) ^ gm0e(A2) ^ gm0b(A3),
                  gm0b(A0) ^ gm0d(A1) ^ gm09(A2) ^ gm0e(A3)};

endmodule
