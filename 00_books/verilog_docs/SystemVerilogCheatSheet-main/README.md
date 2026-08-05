# SystemVerilog 151 – Cheat Sheet / Reference

This is a **quick-reference SystemVerilog (.sv) cheat sheet** for **EECS 151**. It focuses on *synthesizable RTL*, common patterns, and exam/lab‑safe idioms.

---

## 1. Modules

### Module Declaration

```systemverilog
module my_module (
    input  logic a,
    input  logic b,
    output logic c
);
    // logic here
endmodule
```

**Rules**

* File name **must match module name**
* All logic lives inside modules
* Use `logic` (not `wire` / `reg`)

---

## 2. Module Instantiation

### Named Port Connections (preferred)

```systemverilog
my_module u_my_module (
    .a(x),
    .b(y),
    .c(z)
);
```

### Ordered Port Connections (avoid if possible)

```systemverilog
my_module u_my_module (x, y, z);
```

---

## 3. Data Types

### logic

```systemverilog
logic a;          // 1-bit
logic [3:0] bus;  // 4-bit
```

* 4‑state: `0, 1, X, Z`
* Works for combinational + sequential RTL

---

## 4. Parameters

```systemverilog
module adder #(
    parameter int WIDTH = 8
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] sum
);
endmodule
```

Instantiation:

```systemverilog
adder #(.WIDTH(16)) u_adder (...);
```

---

## 5. Combinational Logic

### Continuous Assignments

```systemverilog
assign c = a & b;
assign d = (a > b);
```

### Common Operators

| Type    | Operator          |      |    |
| ------- | ----------------- | ---- | -- |
| Bitwise | `&                | ^ ~` |    |
| Logical | `&&               |      | !` |
| Compare | `> < >= <= == !=` |      |    |
| Shift   | `<< >> <<< >>>`   |      |    |
| Ternary | `?:`              |      |    |

Example:

```systemverilog
assign out = sel ? a : b;
```

---

## 6. always_comb (Combinational)

```systemverilog
always_comb begin
    if (a > b) begin
        greater = 1'b1;
        less    = 1'b0;
        equal   = 1'b0;
    end else if (a < b) begin
        greater = 1'b0;
        less    = 1'b1;
        equal   = 1'b0;
    end else begin
        greater = 1'b0;
        less    = 1'b0;
        equal   = 1'b1;
    end
end
```

**Rules**

* Use **blocking (`=`)** assignments
* Every output **must be assigned in all paths**
* Otherwise → **latch inferred** ❌

---

## 7. Structural Logic (Gate-Level)

```systemverilog
and (d, a, b);
or  (e, a, b);
xor (c, d, e);
```

* Output is **first argument**
* Instance name optional

---

## 8. Multi‑Bit Signals

```systemverilog
logic [7:0] a;
logic [7:0] b;
assign c = a + b;
```

⚠ Width mismatches → truncation or extension + warnings

---

## 9. Sequential Logic

### always_ff (Flip‑Flops)

```systemverilog
always_ff @(posedge clk) begin
    q <= d;
end
```

**Rules**

* Use **non‑blocking (`<=`)** only
* One clock edge per block

---

## 10. Asynchronous Reset

```systemverilog
always_ff @(posedge clk or posedge reset) begin
    if (reset)
        counter <= 2'b00;
    else
        counter <= counter + 1'b1;
end
```

---

## 11. Shift Register (Behavioral)

```systemverilog
always_ff @(posedge clk) begin
    shift_reg <= {shift_reg[2:0], in};
end

assign out = shift_reg;
```

---

## 12. Literals

```systemverilog
1'b0        // binary
4'd10       // decimal
8'hFF       // hex
```

Format: `<width>'<base><value>`

---

## 13. Concatenation, Replication, Slicing

```systemverilog
assign out = {a, b};
assign out = {4{1'b1}};   // 1111
assign x   = y[7:4];
```

---

## 14. Generate Blocks

### Generate For

```systemverilog
genvar i;
generate
    for (i = 0; i < 4; i++) begin
        assign out[i] = a[i] & b[i];
    end
endgenerate
```

### Generate If

```systemverilog
generate
    if (SEL) begin
        booth mul (...);
    end else begin
        wallace mul (...);
    end
endgenerate
```

---

## 15. Decoders (One‑Hot Trick)

```systemverilog
assign one_hot = 16'b1 << addr;
```

---

## 16. Arrays / Memories (2D Nets)

```systemverilog
logic [31:0] regfile [31:0];
assign data = regfile[10];
```

---

## 17. Macros

```systemverilog
`define WIDTH 16
logic [`WIDTH-1:0] bus;
```

Include files:

```systemverilog
`include "constants.svh"
```

---

## 18. localparam

```systemverilog
localparam int OFFSET = 4;
```

* Cannot be overridden
* Safe for internal constants

---

## 19. Latch Pitfall (VERY IMPORTANT)

❌ BAD:

```systemverilog
always_comb begin
    if (sel)
        out = 1'b1;
end
```

✅ GOOD:

```systemverilog
always_comb begin
    out = 1'b0;
    if (sel)
        out = 1'b1;
end
```

---

## 20. Golden Rules for 151

* `always_comb` → blocking (`=`)
* `always_ff` → non‑blocking (`<=`)
* No latches unless explicitly intended
* Prefer behavioral RTL
* Name signals clearly
* Match bit‑widths


---

## Concept Explanations & Intuition (Read This When Things Feel Fuzzy)

### What a Module *Really* Is

A **module** is a block of hardware. Not a function. Not software.

* Every signal exists **all the time**
* Every module runs **in parallel** with every other module
* Instantiating a module means *physically duplicating hardware*

Think: LEGO blocks wired together, not function calls.

---

### logic vs wire vs reg (Why 151 Uses `logic`)

* `wire`: driven continuously (old Verilog)
* `reg`: driven procedurally (old Verilog)
* `logic`: SystemVerilog replacement for *both*

Key idea: **`logic` does NOT mean flip-flop**

> Flip-flops come from `always_ff`, not the type.

---

### Combinational vs Sequential (The Core Mental Model)

**Combinational logic**:

* Output = pure function of inputs
* No memory
* Examples: adders, muxes, comparators
* Written with `assign` or `always_comb`

**Sequential logic**:

* Output depends on *past*
* Has memory (flip-flops)
* Examples: counters, registers, pipelines
* Written with `always_ff`

If there is a **clock**, it is sequential. Period.

---

### assign vs always_comb

```systemverilog
assign y = a & b;
```

Means: *y is always equal to a AND b*

```systemverilog
always_comb begin
    y = a & b;
end
```

Means the **exact same thing**.

Use:

* `assign` → simple expressions
* `always_comb` → conditionals, case statements

---

### Blocking (`=`) vs Non-Blocking (`<=`) — WHY

#### Blocking (`=`)

* Executes **in order**
* Models combinational logic
* Used in `always_comb`

```systemverilog
b = a;
c = b;   // c sees new b
```

#### Non-Blocking (`<=`)

* Executes **in parallel**
* Models flip-flops
* Used in `always_ff`

```systemverilog
b <= a;
c <= b;  // c sees OLD b
```

Mental model:

* `=` → wires settling
* `<=` → registers updating on clock edge

---

### Why Latches Are Bad (and How You Accidentally Create Them)

A **latch** remembers a value *without a clock*.

This happens when:

* A signal is **not assigned in all paths** of `always_comb`

Bad hardware implication:

* Timing depends on signal glitches
* Hard to close timing
* Autograder sadness

Golden fix:

```systemverilog
always_comb begin
    out = 1'b0;   // default
    if (sel)
        out = 1'b1;
end
```

---

### Sensitivity Lists (Why `always_comb` Exists)

Old Verilog:

```systemverilog
always @(a or b or c)
```

If you forget a signal → **buggy hardware** 

SystemVerilog fix:

```systemverilog
always_comb
```

Compiler figures it out. Use this **always** for combinational logic.

---

### Flip-Flops Are Inferred, Not Declared

You do NOT say:

> "make a flip-flop"

You write:

```systemverilog
always_ff @(posedge clk)
    q <= d;
```

Synthesis says:

> "Ah. That’s a D flip-flop."

Hardware is inferred from **behavior**, not keywords.

---

### Reset: Synchronous vs Asynchronous

**Asynchronous reset**:

```systemverilog
always_ff @(posedge clk or posedge reset)
```

* Reset works immediately
* Used in 151 labs

**Synchronous reset**:

```systemverilog
always_ff @(posedge clk)
```

* Reset only happens on clock edge

Follow lab instructions exactly.

---

### Bit-Width Is Hardware Size

```systemverilog
logic [3:0] a;  // 4 wires
```

Hardware consequences:

* Wider = more gates
* Mismatch = truncation or extension

Golden rule:

> Always know how many bits your signal has.

---

### Generate Blocks = Compile-Time Hardware Replication

```systemverilog
for (i = 0; i < 4; i++)
```

Means:

> Create **4 copies** of this hardware

NOT a runtime loop.

If `i` is a `genvar`, it disappears after elaboration.

---

### Behavioral vs Structural (When to Use Which)

**Structural**:

* Explicit gates / flip-flops
* Good for learning
* Painful for large designs

**Behavioral (preferred)**:

* Write intent
* Tools optimize
* What real engineers do

151: learn both
Real life: behavioral RTL

---

### One-Hot Decoders (Why the Shift Trick Works)

```systemverilog
16'b1 << addr
```

Because:

* Binary number shifts the `1` into position
* Hardware = decoder tree
* Clean, fast, readable

---

### Exam Survival Checklist

Before submitting:

* No latches
* Correct assignment type
* Correct bit-widths
* Clocked logic only in `always_ff`
* Combinational logic only in `always_comb`

If confused:

> Ask: *Is this hardware stateful or stateless?*

That question solves 80% of bugs.
