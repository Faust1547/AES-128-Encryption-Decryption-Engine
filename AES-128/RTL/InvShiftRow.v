`timescale 1ns / 1ps
module InvShiftRow #(
    parameter TEXT_LENGTH = 128
)(
    input  wire [TEXT_LENGTH-1:0] Input_state,
    output wire [TEXT_LENGTH-1:0] Output_state
);

assign Output_state[127:120] = Input_state[127:120];
assign Output_state[119:112] = Input_state[23 :16 ];
assign Output_state[111:104] = Input_state[47 :40 ];
assign Output_state[103:96 ] = Input_state[71 :64 ];

assign Output_state[95 :88 ] = Input_state[95 :88 ];
assign Output_state[87 :80 ] = Input_state[119:112];
assign Output_state[79 :72 ] = Input_state[15 :8  ];
assign Output_state[71 :64 ] = Input_state[39 :32 ];

assign Output_state[63 :56 ] = Input_state[63 :56 ];
assign Output_state[55 :48 ] = Input_state[87 :80 ];
assign Output_state[47 :40 ] = Input_state[111:104];
assign Output_state[39 :32 ] = Input_state[7  :0  ];

assign Output_state[31 :24 ] = Input_state[31 :24 ];
assign Output_state[23 :16 ] = Input_state[55 :48 ];
assign Output_state[15 :8  ] = Input_state[79 :72 ];
assign Output_state[7  :0  ] = Input_state[103:96 ];

endmodule
