`timescale 1ns / 1ps
module AddRoundKey #(
    parameter TEXT_LENGTH = 128
)(
    input  wire [TEXT_LENGTH-1:0] Input_state, 
    input  wire [TEXT_LENGTH-1:0] Key,
    output wire [TEXT_LENGTH-1:0] Output_state
);
assign Output_state = Input_state ^ Key;
endmodule
