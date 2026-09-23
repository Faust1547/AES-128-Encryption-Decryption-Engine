`timescale 1ns / 1ps
module TOP#(
    parameter TEXT_GROUP_SIZE = 8,
    parameter TEXT_LENGTH = 128
)(
    input  wire                       clk,
    input  wire                       rst_n,
    
    input  wire                       Mode,
    input  wire                       Start,        
    input  wire [TEXT_GROUP_SIZE-1:0] Data_In,
    input  wire [TEXT_GROUP_SIZE-1:0] Key,
    
    output reg  [TEXT_GROUP_SIZE-1:0] AES_Data_Out,
    output reg                        Finish        
);

localparam IDLE   = 2'd0;
localparam INPUT  = 2'd1;
localparam WAIT   = 2'd2;
localparam OUTPUT = 2'd3;

reg  [TEXT_GROUP_SIZE-1:0] Ciphertext;
reg  [TEXT_GROUP_SIZE-1:0] Decrypt_Plaintext;

reg  [TEXT_LENGTH-1:0] Plaintext_Buffer;
reg  [TEXT_LENGTH-1:0] Key_Buffer;
reg  [TEXT_LENGTH-1:0] Result_Buffer;
wire [TEXT_LENGTH-1:0] Ciphertext_Buffer_Wire;
wire [TEXT_LENGTH-1:0] Decrypt_Plaintext_Wire;

reg  [1:0]  State, Next_State;
reg         Mode_Reg;
reg         Input_Done;
wire        AES_Done;
reg  [2:0]  Counter;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        Ciphertext               <= {TEXT_GROUP_SIZE{1'b0}};
        Plaintext_Buffer         <= {TEXT_LENGTH{1'b0}};
        Key_Buffer               <= {TEXT_LENGTH{1'b0}};
        Result_Buffer            <= {TEXT_LENGTH{1'b0}};
        State                    <= IDLE;
        Input_Done               <= 0;
        Counter                  <= 0;
        Finish                   <= 0;
    end
    else begin
        State <= Next_State;
        Input_Done <= 0;
        Finish     <= 0;
        case (State)
            IDLE: begin
                Counter    <= 0;
                if (Start)
                    Mode_Reg <= Mode;
            end
            INPUT: begin
                case (Counter)
                    32'd0: begin 
                        Plaintext_Buffer[15:0]    <= Data_In;
                        Key_Buffer      [15:0]    <= Key;
                    end
                    32'd1: begin 
                        Plaintext_Buffer[31:16]   <= Data_In;
                        Key_Buffer      [31:16]   <= Key;
                    end
                    32'd2: begin 
                        Plaintext_Buffer[47:32]   <= Data_In;
                        Key_Buffer      [47:32]   <= Key;
                    end 
                    32'd3: begin 
                        Plaintext_Buffer[63:48]   <= Data_In;
                        Key_Buffer      [63:48]   <= Key;
                    end 
                    32'd4: begin 
                        Plaintext_Buffer[79:64]   <= Data_In;
                        Key_Buffer      [79:64]   <= Key;
                    end 
                    32'd5: begin 
                        Plaintext_Buffer[95:80]   <= Data_In;
                        Key_Buffer      [95:80]   <= Key;
                    end 
                    32'd6: begin 
                        Plaintext_Buffer[111:96]  <= Data_In;
                        Key_Buffer      [111:96]  <= Key;
                    end 
                    32'd7: begin 
                        Plaintext_Buffer[127:112] <= Data_In;
                        Key_Buffer      [127:112] <= Key;
                        Input_Done                <= 1'b1;
                    end 
                    default: ;
                endcase
                Counter <= Counter + 1;
            end
            WAIT: begin
                if (AES_Done) 
                    if (!Mode_Reg)
                        Result_Buffer <= Ciphertext_Buffer_Wire;
                    else 
                        Result_Buffer <= Decrypt_Plaintext_Wire;
                Counter <= 0;
            end
            OUTPUT:begin
                if(!Mode_Reg) begin
                    case (Counter)
                        32'd0: AES_Data_Out <= Result_Buffer[15:0];
                        32'd1: AES_Data_Out <= Result_Buffer[31:16];
                        32'd2: AES_Data_Out <= Result_Buffer[47:32];
                        32'd3: AES_Data_Out <= Result_Buffer[63:48];
                        32'd4: AES_Data_Out <= Result_Buffer[79:64];
                        32'd5: AES_Data_Out <= Result_Buffer[95:80];
                        32'd6: AES_Data_Out <= Result_Buffer[111:96];
                        32'd7: begin 
                            AES_Data_Out <= Result_Buffer[127:112];
                            Finish     <= 1'b1;
                        end
                        default: ;
                    endcase
                    Counter <= Counter + 1;
                end 
                else begin
                    case (Counter)
                        32'd0: AES_Data_Out <= Result_Buffer[15:0];
                        32'd1: AES_Data_Out <= Result_Buffer[31:16];
                        32'd2: AES_Data_Out <= Result_Buffer[47:32];
                        32'd3: AES_Data_Out <= Result_Buffer[63:48];
                        32'd4: AES_Data_Out <= Result_Buffer[79:64];
                        32'd5: AES_Data_Out <= Result_Buffer[95:80];
                        32'd6: AES_Data_Out <= Result_Buffer[111:96];
                        32'd7: begin 
                            AES_Data_Out <= Result_Buffer[127:112];
                            Finish     <= 1'b1;
                        end
                        default: ;
                    endcase
                    Counter <= Counter + 1;
                end
               
            end
            default:;
        endcase  
    end 
end

always @(*) begin
    case (State)
        IDLE:   Next_State = Start      ? INPUT  : IDLE;
        INPUT:  Next_State = (Counter == 3'd7) ? WAIT : INPUT;
        WAIT:   Next_State = AES_Done   ? OUTPUT : WAIT;
        OUTPUT: Next_State = (Counter == 3'd7) ? IDLE : OUTPUT;
        default:;
    endcase    
end

Control_Unit_V2 #(
    .TEXT_GROUP_SIZE (TEXT_GROUP_SIZE),
    .TEXT_LENGTH     (TEXT_LENGTH)
)CU2(
    .clk        (clk),
    .rst_n      (rst_n),
    .Mode       (Mode_Reg),
    .Input_Done (Input_Done),
    .Plaintext    (Plaintext_Buffer),
    .Key        (Key_Buffer),
    .Ciphertext (Ciphertext_Buffer_Wire),
    .Decrypt_Plaintext(Decrypt_Plaintext_Wire),
    .AES_Done   (AES_Done)
);
 
endmodule
