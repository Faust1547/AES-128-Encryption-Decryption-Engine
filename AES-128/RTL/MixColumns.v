module MixColumns #(
    parameter TEXT_LENGTH = 128
)(
    input  wire [TEXT_LENGTH-1:0] Input_state,
    output wire [TEXT_LENGTH-1:0] Output_state
);

wire [31:0] Col0, Col1, Col2, Col3;
wire [31:0] Col0_out, Col1_out, Col2_out, Col3_out;

assign Col0 = {
        Input_state[127:120],  // byte 0
        Input_state[119:112],  // byte 1
        Input_state[111:104],  // byte 2
        Input_state[103: 96]   // byte 3
    };

assign Col1 = {
        Input_state[ 95: 88],  // byte 4
        Input_state[ 87: 80],  // byte 5
        Input_state[ 79: 72],  // byte 6
        Input_state[ 71: 64]   // byte 7
    };

assign Col2 = {
        Input_state[ 63: 56],  // byte 8
        Input_state[ 55: 48],  // byte 9
        Input_state[ 47: 40],  // byte 10
        Input_state[ 39: 32]   // byte 11
    };

assign Col3 = {
        Input_state[ 31: 24],  // byte 12
        Input_state[ 23: 16],  // byte 13
        Input_state[ 15:  8],  // byte 14
        Input_state[  7:  0]   // byte 15
    };

MixColumnUnit m0 (.Col_in(Col0), .Col_out(Col0_out));
MixColumnUnit m1 (.Col_in(Col1), .Col_out(Col1_out));
MixColumnUnit m2 (.Col_in(Col2), .Col_out(Col2_out));
MixColumnUnit m3 (.Col_in(Col3), .Col_out(Col3_out));

assign Output_state = {
        Col0_out[31:24], Col0_out[23:16], Col0_out[15:8], Col0_out[7:0],
        Col1_out[31:24], Col1_out[23:16], Col1_out[15:8], Col1_out[7:0],
        Col2_out[31:24], Col2_out[23:16], Col2_out[15:8], Col2_out[7:0],
        Col3_out[31:24], Col3_out[23:16], Col3_out[15:8], Col3_out[7:0]
    };
endmodule