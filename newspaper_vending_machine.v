// ============================================================
//  Coin-Operated Newspaper Vending Machine
//  Cost: 15 cents | Accepts: Nickels (N=5¢) and Dimes (D=10¢)
//  Valid combinations: N+D, N+N+N, D+N, D+D (no change returned)
//  Author: VLSI Major Project
// ============================================================
//
//  STATE ENCODING (Binary):
//  S0  = 000  → 0  cents deposited  (IDLE)
//  S5  = 001  → 5  cents deposited
//  S10 = 010  → 10 cents deposited
//  S15 = 011  → 15+ cents deposited (DISPENSE)
//
//  INPUTS:
//    clk   - Clock signal
//    rst   - Synchronous active-high reset
//    N     - Nickel inserted (5 cents)
//    D     - Dime inserted   (10 cents)
//
//  OUTPUT:
//    dispense - HIGH for one clock cycle when newspaper is dispensed
// ============================================================

module newspaper_vending_machine (
    input  wire clk,
    input  wire rst,
    input  wire N,       // Nickel = 5 cents
    input  wire D,       // Dime   = 10 cents
    output reg  dispense // 1 = dispense newspaper
);

    // ── State encoding ──────────────────────────────────────────
    localparam S0  = 2'b00;   //  0 cents
    localparam S5  = 2'b01;   //  5 cents
    localparam S10 = 2'b10;   // 10 cents
    localparam S15 = 2'b11;   // 15+ cents → dispense

    reg [1:0] current_state, next_state;

    // ── State Register (sequential) ─────────────────────────────
    always @(posedge clk) begin
        if (rst)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    // ── Next-State Logic (combinational) ────────────────────────
    always @(*) begin
        next_state = S0;          // default: return to idle after dispense
        case (current_state)
            S0: begin
                if      (N) next_state = S5;
                else if (D) next_state = S10;
                else         next_state = S0;
            end
            S5: begin
                if      (N) next_state = S10;
                else if (D) next_state = S15;   // N+D → 15¢
                else         next_state = S5;
            end
            S10: begin
                if      (N) next_state = S15;   // D+N or N+N+N path
                else if (D) next_state = S15;   // D+D → 20¢ (no change)
                else         next_state = S10;
            end
            S15: begin
                // Dispense state – always return to idle
                next_state = S0;
            end
            default: next_state = S0;
        endcase
    end

    // ── Output Logic (Moore machine) ────────────────────────────
    always @(*) begin
        dispense = (current_state == S15) ? 1'b1 : 1'b0;
    end

endmodule
