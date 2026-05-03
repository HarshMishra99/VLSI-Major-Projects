// ============================================================
//  Testbench: Coin-Operated Newspaper Vending Machine
//  Tests ALL valid and invalid coin sequences
// ============================================================

`timescale 1ns / 1ps

module tb_newspaper_vending_machine;

    // ── DUT Ports ────────────────────────────────────────────────
    reg  clk, rst, N, D;
    wire dispense;

    // ── Instantiate DUT ──────────────────────────────────────────
    newspaper_vending_machine uut (
        .clk     (clk),
        .rst     (rst),
        .N       (N),
        .D       (D),
        .dispense(dispense)
    );

    // ── Clock: 10 ns period ──────────────────────────────────────
    initial clk = 0;
    always #5 clk = ~clk;

    // ── Helper task: insert one coin, wait one clock ─────────────
    task insert_nickel;
        begin
            N = 1; D = 0;
            @(posedge clk); #1;
            N = 0;
        end
    endtask

    task insert_dime;
        begin
            D = 1; N = 0;
            @(posedge clk); #1;
            D = 0;
        end
    endtask

    task wait_cycle;
        begin
            N = 0; D = 0;
            @(posedge clk); #1;
        end
    endtask

    task do_reset;
        begin
            rst = 1;
            @(posedge clk); #1;
            rst = 0;
        end
    endtask

    // ── VCD dump ─────────────────────────────────────────────────
    initial begin
        $dumpfile("newspaper_vending_machine.vcd");
        $dumpvars(0, tb_newspaper_vending_machine);
    end

    // ── Stimulus ─────────────────────────────────────────────────
    initial begin
        $display("==========================================================");
        $display("  Newspaper Vending Machine Testbench");
        $display("  Newspaper price: 15 cents");
        $display("==========================================================\n");

        // Initialise
        N = 0; D = 0; rst = 0;
        do_reset;

        // ----------------------------------------------------------
        // TEST 1: Nickel → Dime  (N + D = 15¢)
        // ----------------------------------------------------------
        $display("TEST 1: Nickel then Dime  [N→D] — expects DISPENSE");
        insert_nickel;
        $display("  After Nickel  | state should be S5  | dispense=%b", dispense);
        insert_dime;
        $display("  After Dime    | state should be S15 | dispense=%b", dispense);
        wait_cycle;
        $display("  After wait    | state should be S0  | dispense=%b\n", dispense);
        do_reset;

        // ----------------------------------------------------------
        // TEST 2: Three Nickels  (N + N + N = 15¢)
        // ----------------------------------------------------------
        $display("TEST 2: Three Nickels     [N→N→N] — expects DISPENSE");
        insert_nickel;
        $display("  After 1st N   | dispense=%b", dispense);
        insert_nickel;
        $display("  After 2nd N   | dispense=%b", dispense);
        insert_nickel;
        $display("  After 3rd N   | dispense=%b  <-- should be 1", dispense);
        wait_cycle;
        $display("  After wait    | dispense=%b\n", dispense);
        do_reset;

        // ----------------------------------------------------------
        // TEST 3: Dime → Nickel  (D + N = 15¢)
        // ----------------------------------------------------------
        $display("TEST 3: Dime then Nickel  [D→N] — expects DISPENSE");
        insert_dime;
        $display("  After Dime    | dispense=%b", dispense);
        insert_nickel;
        $display("  After Nickel  | dispense=%b  <-- should be 1", dispense);
        wait_cycle;
        $display("  After wait    | dispense=%b\n", dispense);
        do_reset;

        // ----------------------------------------------------------
        // TEST 4: Two Dimes  (D + D = 20¢ — no change returned)
        // ----------------------------------------------------------
        $display("TEST 4: Two Dimes         [D→D] — expects DISPENSE (no change)");
        insert_dime;
        $display("  After 1st D   | dispense=%b", dispense);
        insert_dime;
        $display("  After 2nd D   | dispense=%b  <-- should be 1", dispense);
        wait_cycle;
        $display("  After wait    | dispense=%b\n", dispense);
        do_reset;

        // ----------------------------------------------------------
        // TEST 5: Only a Dime (D = 10¢ — not enough)
        // ----------------------------------------------------------
        $display("TEST 5: Only one Dime     [D] — NO dispense");
        insert_dime;
        $display("  After Dime    | dispense=%b  <-- should be 0", dispense);
        wait_cycle;
        $display("  After wait    | dispense=%b\n", dispense);
        do_reset;

        // ----------------------------------------------------------
        // TEST 6: Only one Nickel (N = 5¢ — not enough)
        // ----------------------------------------------------------
        $display("TEST 6: Only one Nickel   [N] — NO dispense");
        insert_nickel;
        $display("  After Nickel  | dispense=%b  <-- should be 0", dispense);
        wait_cycle;
        $display("  After wait    | dispense=%b\n", dispense);
        do_reset;

        // ----------------------------------------------------------
        // TEST 7: Two Nickels (N + N = 10¢ — not enough)
        // ----------------------------------------------------------
        $display("TEST 7: Two Nickels       [N→N] — NO dispense");
        insert_nickel;
        insert_nickel;
        $display("  After 2 N     | dispense=%b  <-- should be 0", dispense);
        wait_cycle;
        $display("  After wait    | dispense=%b\n", dispense);
        do_reset;

        // ----------------------------------------------------------
        // TEST 8: Reset mid-sequence
        // ----------------------------------------------------------
        $display("TEST 8: Reset mid-sequence [N→N→RESET→D] — NO dispense");
        insert_nickel;
        insert_nickel;
        $display("  After 2 N     | dispense=%b", dispense);
        do_reset;
        $display("  After RESET   | dispense=%b  <-- should be 0", dispense);
        insert_dime;
        $display("  After Dime    | dispense=%b  <-- should be 0 (only 10 cents)", dispense);
        wait_cycle;
        $display("  After wait    | dispense=%b\n", dispense);
        do_reset;

        $display("==========================================================");
        $display("  All tests complete.");
        $display("==========================================================");
        $finish;
    end

    // ── Waveform monitor ─────────────────────────────────────────
    initial begin
        $monitor("Time=%0t | clk=%b rst=%b N=%b D=%b | state=%b | dispense=%b",
                 $time, clk, rst, N, D, uut.current_state, dispense);
    end

endmodule
