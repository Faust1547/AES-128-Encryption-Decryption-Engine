module Control_Unit_V2 #(
    parameter TEXT_GROUP_SIZE = 16,
    parameter TEXT_LENGTH     = 128
)(
    input  wire                   clk,
    input  wire                   rst_n,

    input  wire                   Mode,          // 0: Encrypt, 1: Decrypt
    input  wire                   Input_Done,    // One-cycle pulse: input data/key are ready
    input  wire [TEXT_LENGTH-1:0] Plaintext,     // Mode=0: plaintext, Mode=1: ciphertext input
    input  wire [TEXT_LENGTH-1:0] Key,

    output reg  [TEXT_LENGTH-1:0] Ciphertext,
    output reg  [TEXT_LENGTH-1:0] Decrypt_Plaintext,
    output reg                    AES_Done       // One-cycle pulse
);

// ============================================================
// FSM States
// ============================================================
localparam IDLE              = 4'd0;
localparam KEY_EXPAND        = 4'd1;

localparam ENC_INIT          = 4'd2;
localparam ENC_SUB_SHIFT     = 4'd3;
localparam ENC_MIX_ADD       = 4'd4;
localparam ENC_FINAL         = 4'd5;

localparam DEC_INIT          = 4'd6;
localparam DEC_INV_SHIFT_SUB = 4'd7;
localparam DEC_ADD_INV_MIX   = 4'd8;
localparam DEC_FINAL         = 4'd9;

localparam DONE              = 4'd10;

reg [3:0] State, Next_State;

// ============================================================
// Transaction Registers
// ============================================================
reg                   Mode_Reg;
reg [TEXT_LENGTH-1:0] Input_Data_Reg;
reg [TEXT_LENGTH-1:0] State_Reg;

// ============================================================
// Round-Key Storage / Key Expansion
// ============================================================
reg  [3:0]             Key_Counter;
reg  [3:0]             Round_Counter;
reg  [TEXT_LENGTH-1:0] Round_Key_Reg;
wire [TEXT_LENGTH-1:0] Expanded_Key;

reg [TEXT_LENGTH-1:0] Round_Key_Mem [0:10];

KeyExpansion #(
    .TEXT_LENGTH (TEXT_LENGTH)
) KE (
    .Current_key (Round_Key_Reg),
    .Round       (Key_Counter),
    .Next_Key    (Expanded_Key)
);

// ============================================================
// Encryption Datapath
// SubBytes -> ShiftRows
// ============================================================
wire [TEXT_LENGTH-1:0] SubByte_To_ShiftRow;
wire [TEXT_LENGTH-1:0] ShiftRow_Result;
reg  [TEXT_LENGTH-1:0] ShiftRow_Result_Reg;

SubByte #(
    .TEXT_LENGTH (TEXT_LENGTH)
) SB (
    .Input_state  (State_Reg),
    .Output_state (SubByte_To_ShiftRow)
);

ShiftRow #(
    .TEXT_LENGTH (TEXT_LENGTH)
) SR (
    .Input_state  (SubByte_To_ShiftRow),
    .Output_state (ShiftRow_Result)
);

// ============================================================
// Encryption Datapath
// MixColumns -> AddRoundKey
// Final round bypasses MixColumns
// ============================================================
wire [TEXT_LENGTH-1:0] MixColumns_To_AddRoundKey;
wire [TEXT_LENGTH-1:0] Encrypt_AddRoundKey_Input;
wire [TEXT_LENGTH-1:0] Encrypt_AddRoundKey_Result;

MixColumns #(
    .TEXT_LENGTH (TEXT_LENGTH)
) MC (
    .Input_state  (ShiftRow_Result_Reg),
    .Output_state (MixColumns_To_AddRoundKey)
);

assign Encrypt_AddRoundKey_Input =
    (Round_Counter == 4'd10)
    ? ShiftRow_Result_Reg
    : MixColumns_To_AddRoundKey;

AddRoundKey #(
    .TEXT_LENGTH (TEXT_LENGTH)
) ARK (
    .Input_state  (Encrypt_AddRoundKey_Input),
    .Key          (Round_Key_Mem[Round_Counter]),
    .Output_state (Encrypt_AddRoundKey_Result)
);

// ============================================================
// Decryption Datapath
// InvShiftRows -> InvSubBytes
// ============================================================
wire [TEXT_LENGTH-1:0] InvShiftRow_To_SubByte;
wire [TEXT_LENGTH-1:0] InvSubByte_Result;
reg  [TEXT_LENGTH-1:0] InvSubByte_Result_Reg;

InvShiftRow #(
    .TEXT_LENGTH (TEXT_LENGTH)
) ISR (
    .Input_state  (State_Reg),
    .Output_state (InvShiftRow_To_SubByte)
);

InvSubByte #(
    .TEXT_LENGTH (TEXT_LENGTH)
) ISB (
    .Input_state  (InvShiftRow_To_SubByte),
    .Output_state (InvSubByte_Result)
);

// ============================================================
// Decryption Datapath
// AddRoundKey -> InvMixColumns
// ============================================================
wire [TEXT_LENGTH-1:0] Decrypt_AddRoundKey_Result;
wire [TEXT_LENGTH-1:0] InvMixColumns_Result;

AddRoundKey #(
    .TEXT_LENGTH (TEXT_LENGTH)
) IARK (
    .Input_state  (InvSubByte_Result_Reg),
    .Key          (Round_Key_Mem[Round_Counter]),
    .Output_state (Decrypt_AddRoundKey_Result)
);

InvMixColumns #(
    .TEXT_LENGTH (TEXT_LENGTH)
) IMC (
    .Input_state  (Decrypt_AddRoundKey_Result),
    .Output_state (InvMixColumns_Result)
);

// ============================================================
// Sequential Logic
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        State             <= IDLE;
        Mode_Reg          <= 1'b0;
        Input_Data_Reg    <= {TEXT_LENGTH{1'b0}};
        State_Reg         <= {TEXT_LENGTH{1'b0}};
        Key_Counter       <= 4'd0;
        Round_Counter     <= 4'd0;
        Round_Key_Reg     <= {TEXT_LENGTH{1'b0}};
        ShiftRow_Result_Reg   <= {TEXT_LENGTH{1'b0}};
        InvSubByte_Result_Reg <= {TEXT_LENGTH{1'b0}};
        Ciphertext        <= {TEXT_LENGTH{1'b0}};
        Decrypt_Plaintext <= {TEXT_LENGTH{1'b0}};
        AES_Done          <= 1'b0;
    end
    else begin
        State    <= Next_State;
        AES_Done <= 1'b0;
        case (State)
            IDLE: begin
                if (Input_Done) begin
                    Mode_Reg       <= Mode;
                    Input_Data_Reg <= Plaintext;

                    Round_Key_Mem[0] <= Key;
                    Round_Key_Reg    <= Key;
                    Key_Counter      <= 4'd1;
                end
            end

            KEY_EXPAND: begin
                Round_Key_Mem[Key_Counter] <= Expanded_Key;
                Round_Key_Reg              <= Expanded_Key;

                if (Key_Counter < 4'd10)
                    Key_Counter <= Key_Counter + 1'b1;
            end
            
            ENC_INIT: begin
                State_Reg     <= Input_Data_Reg ^ Round_Key_Mem[0];
                Round_Counter <= 4'd1;
            end

            ENC_SUB_SHIFT: 
                ShiftRow_Result_Reg <= ShiftRow_Result;

            ENC_MIX_ADD: begin
                State_Reg     <= Encrypt_AddRoundKey_Result;
                Round_Counter <= Round_Counter + 1'b1;
            end

            ENC_FINAL: 
                Ciphertext <= Encrypt_AddRoundKey_Result;

            DEC_INIT: begin
                State_Reg     <= Input_Data_Reg ^ Round_Key_Mem[10];
                Round_Counter <= 4'd9;
            end

            DEC_INV_SHIFT_SUB: 
                InvSubByte_Result_Reg <= InvSubByte_Result;

            DEC_ADD_INV_MIX: begin
                State_Reg     <= InvMixColumns_Result;
                Round_Counter <= Round_Counter - 1'b1;
            end

            DEC_FINAL: 
                Decrypt_Plaintext <= Decrypt_AddRoundKey_Result;

            DONE: 
                AES_Done <= 1'b1;

            default:;
        endcase
    end
end

// ============================================================
// Next-State Logic
// ============================================================
always @(*) begin
    Next_State = IDLE;
    case (State)
        IDLE:          Next_State = Input_Done ? KEY_EXPAND : IDLE;
        KEY_EXPAND: 
            if (Key_Counter == 4'd10) Next_State = Mode_Reg ? DEC_INIT : ENC_INIT;
            else       Next_State = KEY_EXPAND;
            
        ENC_INIT: Next_State = ENC_SUB_SHIFT;
        ENC_SUB_SHIFT: Next_State = (Round_Counter == 4'd10) ? ENC_FINAL : ENC_MIX_ADD;
        ENC_MIX_ADD:   Next_State = ENC_SUB_SHIFT;
        ENC_FINAL:     Next_State = DONE;
        
        DEC_INIT:          Next_State = DEC_INV_SHIFT_SUB;
        DEC_INV_SHIFT_SUB: Next_State = (Round_Counter == 4'd0) ? DEC_FINAL : DEC_ADD_INV_MIX;
        DEC_ADD_INV_MIX:   Next_State = DEC_INV_SHIFT_SUB;
        DEC_FINAL:         Next_State = DONE;
        DONE:              Next_State = IDLE;
        default:           Next_State = IDLE;
    endcase
end

endmodule
