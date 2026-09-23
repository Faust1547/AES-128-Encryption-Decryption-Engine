`timescale 1ns / 1ps
module SubByte #(
    parameter TEXT_LENGTH = 128
)(
    input  wire [TEXT_LENGTH-1:0] Input_state,
    output wire [TEXT_LENGTH-1:0] Output_state
);

S_Box Sbox_00 (.S_In(Input_state[127:120]), .S_Out(Output_state[127:120]));
S_Box Sbox_01 (.S_In(Input_state[119:112]), .S_Out(Output_state[119:112]));
S_Box Sbox_02 (.S_In(Input_state[111:104]), .S_Out(Output_state[111:104]));
S_Box Sbox_03 (.S_In(Input_state[103:96 ]), .S_Out(Output_state[103:96 ]));
S_Box Sbox_04 (.S_In(Input_state[95 :88 ]), .S_Out(Output_state[95 :88 ]));
S_Box Sbox_05 (.S_In(Input_state[87 :80 ]), .S_Out(Output_state[87 :80 ]));
S_Box Sbox_06 (.S_In(Input_state[79 :72 ]), .S_Out(Output_state[79 :72 ]));
S_Box Sbox_07 (.S_In(Input_state[71 :64 ]), .S_Out(Output_state[71 :64 ]));
S_Box Sbox_08 (.S_In(Input_state[63 :56 ]), .S_Out(Output_state[63 :56 ]));
S_Box Sbox_09 (.S_In(Input_state[55 :48 ]), .S_Out(Output_state[55 :48 ]));
S_Box Sbox_10 (.S_In(Input_state[47 :40 ]), .S_Out(Output_state[47 :40 ]));
S_Box Sbox_11 (.S_In(Input_state[39 :32 ]), .S_Out(Output_state[39 :32 ]));
S_Box Sbox_12 (.S_In(Input_state[31 :24 ]), .S_Out(Output_state[31 :24 ]));
S_Box Sbox_13 (.S_In(Input_state[23 :16 ]), .S_Out(Output_state[23 :16 ]));
S_Box Sbox_14 (.S_In(Input_state[15 :8  ]), .S_Out(Output_state[15 :8  ]));
S_Box Sbox_15 (.S_In(Input_state[7  :0  ]), .S_Out(Output_state[7  :0  ]));

endmodule
