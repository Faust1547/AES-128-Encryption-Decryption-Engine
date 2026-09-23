module KeyExpansion #(
    parameter TEXT_LENGTH = 128
)(
    input  wire [TEXT_LENGTH-1:0] Current_key,
    input  wire [3:0]             Round,
    output wire [TEXT_LENGTH-1:0] Next_Key
);

wire [31:0] w0 = Current_key[127:96];
wire [31:0] w1 = Current_key[95:64];
wire [31:0] w2 = Current_key[63:32];
wire [31:0] w3 = Current_key[31:0];
wire [31:0] w4;
wire [31:0] w5;
wire [31:0] w6;
wire [31:0] w7;

wire [31:0] RotWord;
wire [31:0] SubWord_Result;

assign RotWord = {w3[23:0], w3[31:24]};

S_Box SB0 (
    .S_In  (RotWord[31:24]),
    .S_Out (SubWord_Result[31:24])
);

S_Box SB1 (
    .S_In  (RotWord[23:16]),
    .S_Out (SubWord_Result[23:16])
);

S_Box SB2 (
    .S_In  (RotWord[15:8]),
    .S_Out (SubWord_Result[15:8])
);

S_Box SB3 (
    .S_In  (RotWord[7:0]),
    .S_Out (SubWord_Result[7:0])
);

assign w4 = w0 ^ SubWord_Result ^ Rcon(Round);
assign w5 = w1 ^ w4;
assign w6 = w2 ^ w5;
assign w7 = w3 ^ w6;
assign Next_Key = {w4,w5,w6,w7};

function [31:0] Rcon;
	input [3:0] Rc;
	begin
        case (Rc)
            4'h1: Rcon = 32'h01000000;
            4'h2: Rcon = 32'h02000000;
            4'h3: Rcon = 32'h04000000;
            4'h4: Rcon = 32'h08000000;
            4'h5: Rcon = 32'h10000000;
            4'h6: Rcon = 32'h20000000;
            4'h7: Rcon = 32'h40000000;
            4'h8: Rcon = 32'h80000000;
            4'h9: Rcon = 32'h1B000000;
            4'hA: Rcon = 32'h36000000;
            default: Rcon = 32'h00000000;
        endcase
	end
endfunction

endmodule
