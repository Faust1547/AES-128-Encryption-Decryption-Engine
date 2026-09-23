module InvSubByte #(
    parameter TEXT_LENGTH = 128
)(
    input  wire [TEXT_LENGTH-1:0] Input_state,
    output wire [TEXT_LENGTH-1:0] Output_state
);

Inv_S_Box Inv_Sbox_00 (.S_In(Input_state[127:120]), .S_Out(Output_state[127:120]));
Inv_S_Box Inv_Sbox_01 (.S_In(Input_state[119:112]), .S_Out(Output_state[119:112]));
Inv_S_Box Inv_Sbox_02 (.S_In(Input_state[111:104]), .S_Out(Output_state[111:104]));
Inv_S_Box Inv_Sbox_03 (.S_In(Input_state[103:96 ]), .S_Out(Output_state[103:96 ]));
Inv_S_Box Inv_Sbox_04 (.S_In(Input_state[95 :88 ]), .S_Out(Output_state[95 :88 ]));
Inv_S_Box Inv_Sbox_05 (.S_In(Input_state[87 :80 ]), .S_Out(Output_state[87 :80 ]));
Inv_S_Box Inv_Sbox_06 (.S_In(Input_state[79 :72 ]), .S_Out(Output_state[79 :72 ]));
Inv_S_Box Inv_Sbox_07 (.S_In(Input_state[71 :64 ]), .S_Out(Output_state[71 :64 ]));
Inv_S_Box Inv_Sbox_08 (.S_In(Input_state[63 :56 ]), .S_Out(Output_state[63 :56 ]));
Inv_S_Box Inv_Sbox_09 (.S_In(Input_state[55 :48 ]), .S_Out(Output_state[55 :48 ]));
Inv_S_Box Inv_Sbox_10 (.S_In(Input_state[47 :40 ]), .S_Out(Output_state[47 :40 ]));
Inv_S_Box Inv_Sbox_11 (.S_In(Input_state[39 :32 ]), .S_Out(Output_state[39 :32 ]));
Inv_S_Box Inv_Sbox_12 (.S_In(Input_state[31 :24 ]), .S_Out(Output_state[31 :24 ]));
Inv_S_Box Inv_Sbox_13 (.S_In(Input_state[23 :16 ]), .S_Out(Output_state[23 :16 ]));
Inv_S_Box Inv_Sbox_14 (.S_In(Input_state[15 :8  ]), .S_Out(Output_state[15 :8  ]));
Inv_S_Box Inv_Sbox_15 (.S_In(Input_state[7  :0  ]), .S_Out(Output_state[7  :0  ]));

endmodule
