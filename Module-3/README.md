<div align="center">

# ⚡ Module 3 — Combinational and Sequential Optimization

### *Trimming the Fat: How Yosys Turns RTL into Lean, Efficient Silicon*

<img src="https://img.shields.io/badge/Language-Verilog-9c27b0?style=for-the-badge&logo=v&logoColor=white" alt="Verilog">
<img src="https://img.shields.io/badge/Tool-Icarus%20Verilog-2196f3?style=for-the-badge&logo=icons8&logoColor=white" alt="Icarus Verilog">
<img src="https://img.shields.io/badge/Tool-GTKWave-ff9800?style=for-the-badge&logo=waveshare&logoColor=white" alt="GTKWave">
<img src="https://img.shields.io/badge/Tool-Yosys-4caf50?style=for-the-badge&logo=opensourcehardware&logoColor=white" alt="Yosys">
<img src="https://img.shields.io/badge/PDK-SKY130-e91e63?style=for-the-badge&logo=chip&logoColor=white" alt="SKY130">

<br>

<img src="https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square">
<img src="https://img.shields.io/badge/OS-Linux%20(Ubuntu)-blueviolet?style=flat-square">
<img src="https://img.shields.io/badge/Focus-Logic%20Optimization-yellow?style=flat-square">

<sub>🔗 Part of the <a href="https://github.com/ArpithaGarrepalli/RTL_Workshop"><b>RTL Workshop</b></a> series</sub>

</div>

---

## 🎯 Objectives

> 🧠 Understand the concept of **logic optimization** in digital circuits
> ⚙️ Study **combinational** and **sequential** logic optimization techniques
> 🔨 Perform synthesis using the **Yosys** synthesis tool
> 🗺️ Map Verilog designs to the **SKY130** standard-cell library
> 🧪 Simulate Verilog designs using **Icarus Verilog** and verify with **GTKWave**
> 🔍 Analyze **optimized gate-level netlists** generated after synthesis

<table>
<tr><td>💻 <b>HDL</b></td><td>Verilog</td></tr>
<tr><td>🧪 <b>Simulator</b></td><td>Icarus Verilog</td></tr>
<tr><td>📊 <b>Waveform Viewer</b></td><td>GTKWave</td></tr>
<tr><td>⚡ <b>Synthesis Tool</b></td><td>Yosys</td></tr>
<tr><td>📚 <b>PDK</b></td><td>SKY130</td></tr>
<tr><td>🐧 <b>OS</b></td><td>Linux (Ubuntu)</td></tr>
</table>

---

## 📑 Table of Contents

| # | Section |
|:-:|---|
| 1️⃣ | [Combinational Logic Optimization](#1️⃣-combinational-logic-optimization) |
| 2️⃣ | [Sequential Logic Optimization](#2️⃣-sequential-logic-optimization) |
| 3️⃣ | [Constant Propagation](#3️⃣-constant-propagation) |
| 4️⃣ | [Combinational Gate Optimization Labs](#4️⃣-combinational-gate-optimization-labs) |
| 5️⃣ | [Sequential Optimization Labs](#5️⃣-sequential-optimization-labs) |
| 6️⃣ | [Unused Output & Counter Optimization](#6️⃣-unused-output--counter-optimization) |
| 7️⃣ | [Other Optimization Techniques](#7️⃣-other-optimization-techniques) |
| 8️⃣ | [Yosys Optimization Passes](#8️⃣-yosys-optimization-passes) |
| 🏁 | [Overall Result](#-overall-result) |
| 📌 | [Conclusion](#-conclusion) |

---

## 1️⃣ Combinational Logic Optimization

> 🟣 **Logic optimization** reduces hardware area, power, and delay — **without changing** the intended functionality of a design. After RTL is converted into logic gates, the synthesis tool analyzes it, removes redundant hardware, simplifies Boolean expressions, and produces a leaner gate-level implementation.

Combinational optimization specifically targets logic **with no memory** — it looks purely at Boolean expressions and strips out anything redundant.

### 🎯 Objectives

<table>
<tr><td>🔽</td><td>Reduce the number of logic gates</td></tr>
<tr><td>🧮</td><td>Simplify Boolean expressions</td></tr>
<tr><td>📐</td><td>Minimize chip area</td></tr>
<tr><td>🚀</td><td>Improve circuit speed</td></tr>
<tr><td>🔋</td><td>Reduce power consumption</td></tr>
</table>

---
<img width="1254" height="660" alt="1" src="https://github.com/user-attachments/assets/0142ab0f-19c4-4290-bcca-32c8ec80d108" />


## 2️⃣ Sequential Logic Optimization

Sequential optimization applies to circuits containing memory elements such as **flip-flops**. Unlike combinational optimization, the tool must **preserve sequential behavior** while removing unnecessary registers and simplifying the logic connected to them.
<img width="1214" height="651" alt="2" src="https://github.com/user-attachments/assets/17cb0e72-cf0f-49b0-a47c-343b03c00b3b" />


**Figure 1:** Sequential optimization techniques overview — sequential constant propagation, retiming, and state optimization.

### 🎯 Typical Goals

- 🗑️ Removing redundant flip-flops
- 📡 Propagating constant values through sequential logic
- 🚫 Eliminating unreachable logic
- ⏱️ Improving timing while maintaining functional equivalence

> ✅ **Result:** Sequential optimization techniques were studied to understand how they improve circuit performance and efficiency.

---

## 3️⃣ Constant Propagation

> Constant propagation replaces signals that always carry a **fixed logic value directly with that constant** during synthesis — instead of building logic to compute an already-known value, the tool substitutes it and strips out redundant gates.


**Figure 2:** Constant propagation — how synthesis tools simplify logic by replacing constant inputs.

<div align="center">

| ✅ Advantage | 💬 Effect |
|---|---|
| Reduces logic complexity | Fewer gates to route and drive |
| Decreases hardware utilization | Smaller silicon footprint |
| Improves timing | Shorter critical paths |
| Lowers power consumption | Less switching activity |

</div>

> ✅ **Result:** The concept of constant propagation was studied to understand how synthesis tools simplify logic by replacing constant inputs. This principle is applied hands-on in the `dff_const1`–`dff_const3` labs in Section 5.

---

## 4️⃣ Combinational Gate Optimization Labs

### ⚙️ 4.1 AND Gate (`opt_check`)

```verilog
module opt_check (
    input a,
    input b,
    output y
);

assign y = a & b;

endmodule
```

```bash
yosys
read_verilog opt_check.v
synth -top opt_check
abc -liberty ../lib/sky130_fd_sc_hd__tt_025C_1v80.lib
show
```

<img width="1600" height="857" alt="3" src="https://github.com/user-attachments/assets/154241d5-1636-465c-8c68-c078cb8e9d16" />

**Figure 3:** AND gate synthesized and mapped to the SKY130 `and2` standard cell.

> ✅ **Result:** The AND gate was successfully synthesized and mapped to the SKY130 `and2` standard cell.

### ⚙️ 4.2 OR Gate (`opt_check2`)

```verilog
module opt_check2 (
    input a,
    input b,
    output y
);

assign y = a | b;

endmodule
```

```bash
yosys
read_verilog opt_check2.v
synth -top opt_check2
abc -liberty ../lib/sky130_fd_sc_hd__tt_025C_1v80.lib
show
```
<img width="1600" height="848" alt="4" src="https://github.com/user-attachments/assets/f1a72bb9-6ba0-49ba-bfad-67e273d02b0b" />


**Figure 4:** OR gate synthesized and mapped to the SKY130 `or2` standard cell.

> ✅ **Result:** The OR gate was synthesized successfully and mapped to the SKY130 `or2` standard cell.

### ⚙️ 4.3 Three-Input AND Gate (`opt_check3`)

```verilog
module opt_check3 (
    input a,
    input b,
    input c,
    output y
);

assign y = a & b & c;

endmodule
```

```bash
yosys
read_verilog opt_check3.v
synth -top opt_check3
abc -liberty ../lib/sky130_fd_sc_hd__tt_025C_1v80.lib
show
```

<img width="1600" height="849" alt="5" src="https://github.com/user-attachments/assets/a74472ba-fde6-4500-b901-46517bcf1582" />

**Figure 5:** Three-input AND gate synthesized and mapped to the SKY130 `and3` standard cell.

> ✅ **Result:** The three-input AND gate was successfully synthesized and mapped to the SKY130 `and3` standard cell.

> ⚠️ **Note:** A separate pair of ternary-based checks (also named `opt_check` / `opt_check2` in the source material — `y = a?b:0` and `y = a?1:b`) were provided as duplicate module names for different logic. Since they overlap in name with the gates above and test the same underlying concept (redundant-logic removal via a constant branch), they've been omitted here in favor of the clearer AND/OR/3-input-AND examples above.

---

## 5️⃣ Sequential Optimization Labs

### 🔴 5.1 `dff_const1` — Reset-to-0, Else-1

```verilog
module dff_const1(input clk, input reset, output reg q);
always @(posedge clk, posedge reset)
begin
    if(reset)
        q <= 1'b0;
    else
        q <= 1'b1;
end
endmodule
```

```bash
iverilog -o dff_const1.out dff_const1.v tb_dff_const1.v
gtkwave tb_dff_const1.vcd

yosys
read_liberty -lib sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog dff_const1.v
synth -top dff_const1
abc -liberty sky130_fd_sc_hd__tt_025C_1v80.lib
show
```
<img width="1912" height="1016" alt="9" src="https://github.com/user-attachments/assets/c75a8047-cb57-46a3-9eed-6e95dd98dfca" />



**Figure 6:** `dff_const1` synthesized netlist — the flip-flop is retained since `q` genuinely depends on `reset`.

<img width="1600" height="846" alt="10" src="https://github.com/user-attachments/assets/ee439ccf-683c-4d58-b629-8846c8e5297e" />


**Figure 7:** Waveform verification — output correctly tracks the reset and clock transitions.

> ✅ **Result:** The synthesized circuit preserved the necessary sequential logic, correctly reflecting the reset-dependent behavior of the original design.

### 🟢 5.2 `dff_const2` — Constant Register (Always `1`)

```verilog
module dff_const2(input clk, input reset, output reg q);
always @(posedge clk, posedge reset)
begin
    if(reset)
        q <= 1'b1;
    else
        q <= 1'b1;
end
endmodule
```

```bash
iverilog -o dff_const2.out dff_const2.v tb_dff_const2_.v
gtkwave tb_dff_const2_.vcd

yosys
read_liberty -lib sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog dff_const2.v
synth -top dff_const2
abc -liberty sky130_fd_sc_hd__tt_025C_1v80.lib
show
```

<img width="1600" height="852" alt="11" src="https://github.com/user-attachments/assets/49aff740-56a8-434c-88db-b99130c3fe0b" />


**Figure 8:** Final optimized `dff_const2` netlist — the flip-flop is replaced with constant logic, since `q` is `1` on every path.

<img width="1917" height="1017" alt="12" src="https://github.com/user-attachments/assets/56fdbaed-c457-4d47-bd48-04469f5015b1" />


**Figure 9:** Waveform confirms the optimized circuit still produces the expected constant output.

> ✨ **Insight:** Because the register **never changes state** — both the reset branch and the normal branch assign `1'b1` — Yosys removes the flip-flop entirely and replaces it with constant logic. No clock or reset circuitry is needed to produce a value that never varies.

> ✅ **Result:** Since the register output always remains at logic `1`, Yosys replaced the flip-flop with constant-driven logic, reducing hardware complexity.

### 🔵 5.3 `dff_const3` — Synchronous Reset Variant

```verilog
module dff_const3(input clk, input reset, output reg q);

always @(posedge clk)
begin
    if(reset)
        q <= 1'b0;
    else
        q <= 1'b1;
end

endmodule
```

```bash
iverilog -o dff_const3.out dff_const3.v dff_const3_tb.v
gtkwave dff_const3.vcd

yosys
read_verilog dff_const3.v
synth -top dff_const3
show
```

<img width="1918" height="1022" alt="14" src="https://github.com/user-attachments/assets/32507cb4-0eee-41b4-ab4b-29023896fd8f" />

**Figure 10:** `dff_const3` synthesized and mapped to SKY130 standard cells — since reset is now *synchronous* (checked only on `posedge clk`), the flip-flop keeps a simpler reset structure than the async versions.

<img width="1600" height="848" alt="15" src="https://github.com/user-attachments/assets/d2ebd778-f1ba-48f8-b176-683e65485eac" />


> ✅ **Result:** Unnecessary sequential logic was identified and optimized while maintaining the expected reset-dependent behavior.

---

## 6️⃣ Unused Output & Counter Optimization

If a signal or output is **never used** by the remaining circuit, Yosys recognizes it has no effect on final functionality and **automatically removes it** — hardware is generated only for logic that actually contributes to the final outputs.

A 3-bit counter demonstrates this clearly: only `count[0]` drives the output, so `count[1]` and `count[2]` are dead weight.

```verilog
module counter_opt(input clk, input reset, output q);

reg [2:0] count;

assign q = count[0];

always @(posedge clk, posedge reset)
begin
    if(reset)
        count <= 3'b000;
    else
        count <= count + 1;
end

endmodule
```

```bash
yosys
read_verilog counter_opt.v
synth -top counter_opt
show
write_verilog -noattr counter_opt_net.v
gvim counter_opt_net.v
```

<img width="958" height="930" alt="Optimized counter circuit" src="https://github.com/user-attachments/assets/6d05c5ac-b53f-4dd9-87b2-4980300107a1" />

**Figure 11:** Optimized gate-level implementation — even though `count` is declared as 3 bits, only **1 flip-flop** survives synthesis.

<img width="958" height="930" alt="Optimized counter netlist" src="https://github.com/user-attachments/assets/bfc5cf2c-211c-41fe-b7f9-374725b41489" />

**Figure 12:** Final optimized counter netlist.

> ✨ **Insight:** `count[1]` and `count[2]` are computed every clock cycle but **never observed** at the output, so Yosys prunes their flip-flops and all the adder logic that feeds them — a clean real-world example of unused-output elimination.

> ✅ **Result:** The synthesized counter retained only the logic required to drive `q`, confirming that synthesis tools generate hardware only for logic that actually contributes to the final outputs.

---

## 7️⃣ Other Optimization Techniques

### 🔀 State Optimization

FSMs can contain equivalent or unreachable states. During optimization, these may be **merged or removed**, cutting hardware while preserving behavior:

- 🔁 Eliminating equivalent states
- 🔢 Efficient state encoding
- 🧮 Simplifying next-state logic
- 📉 Reducing overall hardware complexity

### 🧬 Logic Cloning

Logic cloning **duplicates** selected cells to reduce fan-out and improve timing. Instead of one gate driving many loads, extra copies are created so each one drives fewer destinations — shortening delay on critical timing paths.

### ⏳ Retiming

Retiming **repositions flip-flops across combinational logic** without altering functionality. It balances propagation delays between pipeline stages to boost maximum operating frequency. Unlike other techniques, retiming changes only **register placement** — never the design's logical behavior.

---

## 8️⃣ Yosys Optimization Passes

During synthesis, Yosys automatically runs several optimization passes to simplify the generated hardware:

<div align="center">

| 🛠️ Optimization Pass | 🎯 Purpose |
|---|---|
| 📡 Constant propagation | Replace known-constant signals directly |
| 💀 Dead logic elimination | Remove logic with no effect on outputs |
| 🧮 Boolean simplification | Reduce Boolean expressions |
| 🔌 Removal of unused wires | Remove unreferenced signals |
| 🗑️ Removal of unused cells | Remove unreferenced gates/cells |
| ✨ Expression simplification | Simplify equivalent expressions |
| ♻️ Resource sharing | Reuse hardware across similar operations |

</div>

> ✅ These optimizations collectively produce an efficient, compact gate-level netlist.

---

## 🧪 Laboratory Summary

<div align="center">

| Lab | 🎯 Focus | 🔑 Key Result |
|:-:|---|---|
| 1 | AND / OR / 3-input AND gates | Correctly mapped to SKY130 `and2`, `or2`, `and3` cells |
| 2 | `dff_const1` | Sequential logic preserved — output genuinely depends on reset |
| 3 | `dff_const2` | Always-`1` flip-flop replaced entirely with constant logic |
| 4 | `dff_const3` | Synchronous-reset variant optimized while preserving behavior |
| 5 | `counter_opt` | Unused counter bits and their flip-flops pruned entirely |

</div>

---

## 🏁 Overall Result

- ✅ Studied the concept of **logic optimization** and its impact on area, power, and delay
- ✅ Compared **combinational** and **sequential** optimization techniques
- ✅ Synthesized AND/OR/3-input AND gates and confirmed correct SKY130 cell mapping
- ✅ Verified **constant propagation** through `dff_const1`, `dff_const2`, and `dff_const3`
- ✅ Demonstrated **unused-output elimination** with a 3-bit counter collapsing to a single flip-flop
- ✅ Explored **state optimization**, **logic cloning**, and **retiming** as advanced techniques
- ✅ Catalogued the core optimization passes Yosys runs automatically during synthesis

---

## 📌 Conclusion

<div align="center">

> 🎓 Module 3 provided hands-on understanding of how synthesis tools **optimize RTL designs** — simplifying combinational logic, removing redundant hardware, propagating constants, optimizing sequential elements, and eliminating unused logic, all while preserving intended functionality. These techniques are essential for achieving efficient **area, timing, and power** characteristics in real digital hardware.

</div>
