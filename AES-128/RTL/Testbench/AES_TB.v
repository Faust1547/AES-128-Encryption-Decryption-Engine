`timescale 1ns / 1ps

module AES_TB;

    parameter TEXT_GROUP_SIZE = 8;
    parameter TEXT_LENGTH     = 128;
    parameter CLK_PERIOD      = 2;

    reg                         clk;
    reg                         rst_n;
    reg                         Start;
    reg                         Mode;
    reg  [TEXT_GROUP_SIZE-1:0]  Data_In;
    reg  [TEXT_GROUP_SIZE-1:0]  Key;

    wire [TEXT_GROUP_SIZE-1:0]  AES_Data_Out;
    wire                        Finish;

    integer error_count;
    integer test_count;

    // ============================================================
    // DUT
    // ============================================================
    TOP #(
        .TEXT_GROUP_SIZE (TEXT_GROUP_SIZE),
        .TEXT_LENGTH     (TEXT_LENGTH)
    ) DUT (
        .clk               (clk),
        .rst_n             (rst_n),
        .Mode              (Mode),
        .Start             (Start),
        .Data_In           (Data_In),
        .Key               (Key),
        .AES_Data_Out      (AES_Data_Out),
        .Finish            (Finish)
    );

    // 100 MHz clock when CLK_PERIOD = 10 ns
    initial clk = 1'b0;
    always #(CLK_PERIOD/2) clk = ~clk;


    // ============================================================
    // Reset
    // ============================================================
    task reset_dut;
    begin
        rst_n     = 1'b0;
        Start     = 1'b0;
        Mode      = 1'b0;
        Data_In  = {TEXT_GROUP_SIZE{1'b0}};
        Key       = {TEXT_GROUP_SIZE{1'b0}};

        repeat(3) @(posedge clk);
        #1;
        rst_n = 1'b1;

        repeat(2) @(posedge clk);
    end
    endtask

    task send_input_block;
        input [TEXT_LENGTH-1:0] data_block;
        input [TEXT_LENGTH-1:0] test_key;
        integer i;
    begin
        Start = 1'b1;

        // TOP samples Start in IDLE.
        @(posedge clk);
        #1;
        Start = 1'b0;

        for (i = 0; i < 8; i = i + 1) begin
            Data_In  = data_block[i*16 +: 16];
            Key       = test_key[i*16 +: 16];

            @(posedge clk);
            #1;
        end

        Data_In  = 16'b0;
        Key       = 16'b0;
    end
    endtask


    // ============================================================
    // AES Encryption Test
    // ============================================================
    task run_encrypt_test;
        input [TEXT_LENGTH-1:0] test_plaintext;
        input [TEXT_LENGTH-1:0] test_key;
        input [TEXT_LENGTH-1:0] expected_ciphertext;

        reg [TEXT_LENGTH-1:0] result;
    begin
        test_count = test_count + 1;

        $display("");
        $display("============================================================");
        $display("AES-128 Encryption Test %0d", test_count);
        $display("Plaintext : %032h", test_plaintext);
        $display("Key       : %032h", test_key);
        $display("Expected  : %032h", expected_ciphertext);
        $display("============================================================");

        Mode = 1'b0;
        send_input_block(test_plaintext, test_key);

        result = {TEXT_LENGTH{1'b0}};

        // Keep the newest eight 16-bit output samples.
        while (Finish !== 1'b1) begin
            @(posedge clk);
            #1;
            result = {AES_Data_Out, result[127:16]};
        end

        $display("Result    : %032h", result);

        if (result === expected_ciphertext)
            $display("TEST %0d : PASS", test_count);
        else begin
            $display("TEST %0d : FAIL", test_count);
            error_count = error_count + 1;
        end

        // Wait for TOP to leave OUTPUT and return to IDLE.
        @(posedge clk);
        #1;
        while (Finish === 1'b1) begin
            @(posedge clk);
            #1;
        end

        repeat(2) @(posedge clk);
    end
    endtask

    task run_decrypt_test;
        input [TEXT_LENGTH-1:0] test_ciphertext;
        input [TEXT_LENGTH-1:0] test_key;
        input [TEXT_LENGTH-1:0] expected_plaintext;

        reg [TEXT_LENGTH-1:0] result;
    begin
        test_count = test_count + 1;

        $display("");
        $display("============================================================");
        $display("AES-128 Decryption Test %0d", test_count);
        $display("Ciphertext: %032h", test_ciphertext);
        $display("Key       : %032h", test_key);
        $display("Expected  : %032h", expected_plaintext);
        $display("============================================================");

        Mode = 1'b1;
        send_input_block(test_ciphertext, test_key);

        result = {TEXT_LENGTH{1'b0}};

        while (Finish !== 1'b1) begin
            @(posedge clk);
            #1;
            result = {AES_Data_Out, result[127:16]};
        end

        $display("Result    : %032h", result);

        if (result === expected_plaintext)
            $display("TEST %0d : PASS", test_count);
        else begin
            $display("TEST %0d : FAIL", test_count);
            error_count = error_count + 1;
        end

        @(posedge clk);
        #1;
        while (Finish === 1'b1) begin
            @(posedge clk);
            #1;
        end

        repeat(2) @(posedge clk);
    end
    endtask


    // ============================================================
    // Main Test Sequence
    // ============================================================
    initial begin
        error_count = 0;
        test_count  = 0;

        rst_n       = 1'b1;
        Start       = 1'b0;
        Mode        = 1'b0;
        Data_In    = 16'b0;
        Key         = 16'b0;

        reset_dut();

        // --------------------------------------------------------
        // Encryption Tests
        // --------------------------------------------------------
        run_encrypt_test(
            128'h3243f6a8885a308d313198a2e0370734,
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'h3925841d02dc09fbdc118597196a0b32
        );

        run_encrypt_test(
            128'h6bc1bee22e409f96e93d7e117393172a,
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'h3ad77bb40d7a3660a89ecaf32466ef97
        );

        run_encrypt_test(
            128'hae2d8a571e03ac9c9eb76fac45af8e51,
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'hf5d3d58503b9699de785895a96fdbaaf
        );

        // --------------------------------------------------------
        // Decryption Tests
        // --------------------------------------------------------
        run_decrypt_test(
            128'h3925841d02dc09fbdc118597196a0b32,
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'h3243f6a8885a308d313198a2e0370734
        );

        run_decrypt_test(
            128'h3ad77bb40d7a3660a89ecaf32466ef97,
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'h6bc1bee22e409f96e93d7e117393172a
        );

        run_decrypt_test(
            128'hf5d3d58503b9699de785895a96fdbaaf,
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'hae2d8a571e03ac9c9eb76fac45af8e51
        );

        $display("");
        $display("============================================================");
        if (error_count == 0)
            $display("ALL %0d AES-128 ENCRYPT/DECRYPT TESTS PASSED", test_count);
        else
            $display("%0d / %0d TEST(S) FAILED", error_count, test_count);
        $display("============================================================");

        $finish;
    end

endmodule
