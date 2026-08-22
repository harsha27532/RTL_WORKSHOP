<div align="center">

# ⚡ Module 5 — Optimization in Synthesis

### *Fully Specify or Get a Latch: What Yosys Does With Missing Coverage*

<img src="https://img.shields.io/badge/Language-Verilog-9c27b0?style=for-the-badge&logo=v&logoColor=white" alt="Verilog">
<img src="https://img.shields.io/badge/Tool-Icarus%20Verilog-2196f3?style=for-the-badge&logo=icons8&logoColor=white" alt="Icarus Verilog">
<img src="https://img.shields.io/badge/Tool-GTKWave-ff9800?style=for-the-badge&logo=waveshare&logoColor=white" alt="GTKWave">
<img src="https://img.shields.io/badge/Tool-Yosys-4caf50?style=for-the-badge&logo=opensourcehardware&logoColor=white" alt="Yosys">
<img src="https://img.shields.io/badge/PDK-SKY130-e91e63?style=for-the-badge&logo=chip&logoColor=white" alt="SKY130">

<br>

<img src="https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square">
<img src="https://img.shields.io/badge/Focus-Latch%20Inference-blueviolet?style=flat-square">
<img src="https://img.shields.io/badge/Bug%20Class-Incomplete%20Coverage-yellow?style=flat-square">

<sub>🔗 Part of the <a href="https://github.com/madapaamrutha-svg/RTL_Workshop"><b>RTL Workshop</b></a> series</sub>

</div>

---

## 📖 Overview

> 🟣 This module looks at how Yosys optimizes hardware during synthesis, and — just as importantly — what happens when the RTL doesn't give it enough information to optimize safely.

A set of combinational and sequential circuits were simulated and synthesized to see when Yosys collapses logic down to something minimal and efficient, and when incomplete coding forces it to insert extra hardware just to stay correct. The two outcomes turn out to be **two sides of the same coin**: a synthesis tool can only simplify or share resources when every output is fully defined; the moment a condition is left unhandled, the "optimization" it performs is inserting a **latch** to preserve state — which is rarely what the designer intended.

## 🎯 Objectives

> 🧠 Understand what **synthesis optimization** actually does to an RTL description
> 🔍 Observe **latch inference** caused by incomplete `if` and `case` coding styles
> ⚖️ Compare an **incomplete case statement** against a fully-specified one, in the same design
> 🎯 Recognize that **partial assignment** can occur per-signal, even when a branch looks complete
> 🧪 Verify RTL behavior in **GTKWave** before trusting the synthesized result
> 🔨 Synthesize each design in **Yosys** and inspect the resulting schematic/netlist
> ✅ Confirm, using standard combinational blocks, that **clean RTL synthesizes to clean hardware**

<table>
<tr><td>💻 <b>Verilog HDL</b></td><td>RTL design</td></tr>
<tr><td>🧪 <b>Icarus Verilog</b></td><td>Compiling and simulating designs</td></tr>
<tr><td>📊 <b>GTKWave</b></td><td>Waveform inspection</td></tr>
<tr><td>⚡ <b>Yosys</b></td><td>RTL synthesis and optimization</td></tr>
<tr><td>📚 <b>SKY130 Standard-Cell Library</b></td><td>Technology mapping</td></tr>
<tr><td>🐧 <b>Ubuntu Linux</b></td><td>Development environment</td></tr>
</table>

---

## 📑 Table of Contents

| # | Section |
|:-:|---|
| 1️⃣ | [Incomplete IF Statement](#1️⃣-incomplete-if-statement) |
| 2️⃣ | [Incomplete IF-ELSE Statement](#2️⃣-incomplete-if-else-statement) |
| 3️⃣ | [CASE Statements — Complete vs. Incomplete](#3️⃣-case-statements--complete-vs-incomplete) |
| 4️⃣ | [Combinational Reference Designs](#4️⃣-combinational-reference-designs) |
| 5️⃣ | [Results at a Glance](#5️⃣-results-at-a-glance) |
| 🏁 | [Overall Result](#-overall-result) |
| 📌 | [Conclusion](#-conclusion) |

---

## 1️⃣ Incomplete IF Statement

### 🧪 1.1 Simulating the Incomplete IF

An incomplete `if` statement only assigns its output when a particular condition holds — every other case is left with no assignment at all. Before touching synthesis, the RTL was simulated on its own to see how the output actually behaves.

```bash
iverilog -o incom_if incom_if.v incom_if_tb.v
gtkwave incom_if.vcd
```

<img width="957" height="916" alt="Screenshot 2026-08-22 212409" src="https://github.com/user-attachments/assets/646f57d5-f4cc-4ed0-a47b-55c76c799996" />


**Figure 1:** Simulation waveform of the incomplete `if` statement.

> ⚠️ **Result:** The output only updates while `sel` is asserted; the instant `sel` drops, the output freezes at whatever value it last held rather than changing to reflect the new condition — the waveform confirms the output is undefined for part of the condition space, a sign of memory behavior that shouldn't exist in a purely combinational block.

### ⚡ 1.2 Synthesizing the Incomplete IF

The same RTL was pushed through Yosys to see what hardware it actually resolves to.

```bash
yosys
read_verilog incom_if.v
synth -top incom_if
show
```

<img width="1014" height="922" alt="Screenshot 2026-08-22 212423" src="https://github.com/user-attachments/assets/e4dfa190-b48e-4638-b2ba-4324661e53de" />

**Figure 2:** Synthesized schematic showing an inferred latch.

> ✨ **Insight:** Since the RTL never says what to do outside the one specified condition, the only synthesizable option is to **remember the previous value** — which is exactly what the inferred latch does.

> ⚠️ **Result:** The schematic contains a latch that Yosys inserted specifically to hold the output steady whenever the `if` condition isn't met.

### 🔬 1.3 Closer Look at the Waveform

A second, more detailed pass over the same simulation checks whether the freeze behavior lines up precisely with the condition, or whether it's inconsistent.

```bash
iverilog -o incom_if incom_if.v incom_if_tb.v
gtkwave incom_if.vcd
```

<img width="943" height="912" alt="Screenshot 2026-08-22 212440" src="https://github.com/user-attachments/assets/f901a34a-4a2b-4e6c-a4f4-4c05c2455901" />


**Figure 3:** Detailed waveform trace confirming the freeze aligns exactly with the select signal.

> ✅ **Result:** Every output edge tracks a transition of the select signal; whenever the select signal falls, the output simply stays where it was. This rules out the freeze being a simulation quirk — it's a direct, repeatable consequence of the missing assignment, matching the schematic in 1.2.

---

## 2️⃣ Incomplete IF-ELSE Statement

### ⚡ 2.1 Synthesizing the Incomplete IF-ELSE

This design adds an `else` branch to the earlier `if`, but the branch still doesn't account for every reachable condition.

```bash
yosys
read_verilog incom_if2.v
synth -top incom_if2
show
```

<img width="1010" height="929" alt="Screenshot 2026-08-22 212457" src="https://github.com/user-attachments/assets/bf345b38-c3b4-4d8e-b809-dd6078a8f48f" />


**Figure 4:** Synthesized schematic — a latch still appears despite the `else` branch.

> ✨ **Insight:** Simply having an `else` clause isn't the safeguard it looks like — what matters is whether **every** condition ends in an assignment, not whether an `else` exists at all.

> ⚠️ **Result:** Even with an `else` present, the schematic still shows a latch wherever coverage is incomplete.

---

## 3️⃣ CASE Statements — Complete vs. Incomplete

### 🔴 3.1 Incomplete CASE

```verilog
module incomp_case (input i0, input i1, input i2, input [1:0] sel, output reg y);
    always @(*) begin
        case(sel)
            2'b00 : y = i0;
            2'b01 : y = i1;
        endcase
    end
endmodule
```

Two of the four possible values of `sel` (`2'b10` and `2'b11`) have no matching branch at all.

<img width="943" height="924" alt="Screenshot 2026-08-22 212512" src="https://github.com/user-attachments/assets/a4b4997c-17ab-4b10-bd2f-3ac0b3a2d0ae" />


**Figure 5:** Synthesized netlist of the incomplete `case` — latch inferred.

<img width="946" height="917" alt="Screenshot 2026-08-22 212529" src="https://github.com/user-attachments/assets/cda1c74a-6e23-48ac-be61-f40cd23478c7" />

**Figure 6:** Simulation waveform showing the output holding for the two unhandled `sel` codes.

> ⚠️ **Result:** A `case` statement with missing branches produces exactly the same failure as the incomplete `if` in Section 1 — the mechanism differs, the outcome doesn't.

### 🟢 3.2 Complete CASE

```verilog
module comp_case (input i0, input i1, input i2, input [1:0] sel, output reg y);
    always @(*) begin
        case(sel)
            2'b00   : y = i0;
            2'b01   : y = i1;
            default : y = i2;
        endcase
    end
endmodule
```

<img width="958" height="930" alt="Complete case - synthesized netlist" src="https://github.com/user-attachments/assets/650df85d-feed-4259-8ed3-7fc6acc9e108" />

**Figure 7:** Synthesized netlist of the complete `case` — pure combinational logic, no latch.

<img width="944" height="920" alt="Screenshot 2026-08-22 212554" src="https://github.com/user-attachments/assets/2cb4f196-79ac-41b6-b723-2635e7e23190" />


**Figure 8:** Simulation waveform showing clean switching for every `sel` value.

> ✅ **Result:** Adding a single `default` branch that assigns the output closes every remaining gap — this is the direct fix for 3.1. Once every `sel` value maps to an assignment, Yosys has nothing left to "remember" and synthesizes clean.

### 🟡 3.3 Partial Assignment Inside a CASE

```verilog
module partial_case_assign (input i0, input i1, input i2, input [1:0] sel,
                             output reg y, output reg x);
    always @(*) begin
        case(sel)
            2'b00 : begin y = i0; x = i2; end
            2'b01 : y = i1;
            default : begin x = i1; end
        endcase
    end
endmodule
```

<img width="951" height="921" alt="Screenshot 2026-08-22 212605" src="https://github.com/user-attachments/assets/302f75d0-f352-4ebb-9954-40823bccc95a" />

**Figure 9:** Synthesized netlist — separate latches inferred for `y` and `x`.

<img width="948" height="922" alt="Screenshot 2026-08-22 212619" src="https://github.com/user-attachments/assets/38a8e8c2-d9ae-492f-8116-e1c3de504848" />


**Figure 10:** Waveform showing each signal freezing exactly where its own assignment is missing.

> ✨ **Insight:** The netlist infers a latch for `y` because it's never assigned in the `default` branch, and a separate latch for `x` because it's never assigned in the `2'b01` branch. This case has a `default` branch and *still* infers latches, which shows that branch coverage and per-signal coverage are two different checks.

> ⚠️ **Result:** Every output needs an assignment in every branch, not just every branch needing *an* assignment.

### 🔵 3.4 A Fully-Specified 4-Way CASE

```verilog
module bad_case (input i0, input i1, input i2, input i3, input [1:0] sel, output reg y);
    always @(*) begin
        case(sel)
            2'b00 : y = i0;
            2'b01 : y = i1;
            2'b10 : y = i2;
            2'b11 : y = i3;
        endcase
    end
endmodule
```

<img width="944" height="912" alt="Screenshot 2026-08-22 212631" src="https://github.com/user-attachments/assets/74c8203f-07d0-4865-9435-6bcdc60411df" />


**Figure 11:** Waveform showing correct output switching for all four `sel` combinations.

> ✅ **Result:** Despite its name, this module lists all four possible `sel` combinations explicitly, and the waveform shows the output switching correctly for every one of them. Correctness here comes from the code, not the label — a reminder that "bad_case" as a name doesn't make the coverage bad.

---

## 4️⃣ Combinational Reference Designs

### 🔀 4.1 Multiplexer

<img width="945" height="921" alt="Screenshot 2026-08-22 212646" src="https://github.com/user-attachments/assets/d6eb3df2-2ddc-4dfd-b829-3d11dcb50c9d" />

**Figure 12:** Multiplexer simulation waveform.

> ✅ **Result:** The output tracks whichever input the select line points to, across the full sweep of test values — clean, fully-covered combinational behavior, a good baseline for what "no latch" should look like.

### 🔁 4.2 Demultiplexer

<img width="949" height="930" alt="Screenshot 2026-08-22 212707" src="https://github.com/user-attachments/assets/723931b8-45a2-42b8-a709-b99ee5f15575" />

**Figure 13:** Demultiplexer simulation waveform.

> ✅ **Result:** The single input is routed to exactly one output line at a time, and every other output line stays inactive — correct routing with no stray storage, confirming the demux design covers every select condition.

### ➕ 4.3 Ripple Carry Adder

<img width="947" height="917" alt="Screenshot 2026-08-22 212720" src="https://github.com/user-attachments/assets/007ee8c1-b897-405f-a165-7e4a3717c261" />


**Figure 14:** Ripple carry adder simulation waveform.

> ✅ **Result:** The carry signal propagates correctly through each full-adder stage, and the sum/carry outputs match expected binary addition for every tested input pair — the same "fully-specified means clean synthesis" pattern holds even at the scale of a multi-bit arithmetic circuit.

---

## 5️⃣ Results at a Glance

<div align="center">

| # | Design | Result | Takeaway |
|:-:|---|:---:|---|
| 1.1 | Incomplete IF, sim | ⚠️ | Output freezes when condition is false |
| 1.2 | Incomplete IF, synth | ⚠️ | Latch inferred at the missing branch |
| 1.3 | Incomplete IF, detail | ⚠️ | Freeze behavior confirmed reproducible |
| 2.1 | Incomplete IF-ELSE, synth | ⚠️ | Latch inferred despite else being present |
| 3.1 | Incomplete CASE | ⚠️ | Latch inferred for unhandled sel codes |
| 3.2 | Complete CASE | ✅ | Default branch removes the latch entirely |
| 3.3 | Partial CASE assignment | ⚠️ | Latches inferred per-signal, not per-branch |
| 3.4 | Fully-specified 4-way CASE | ✅ | Every combination assigned, clean switching |
| 4.1 | Multiplexer | ✅ | Clean combinational reference |
| 4.2 | Demultiplexer | ✅ | Clean combinational reference |
| 4.3 | Ripple Carry Adder | ✅ | Clean at multi-bit arithmetic scale |

</div>

---

## 🏁 Overall Result

- ⚠️ Confirmed **latch inference** from an incomplete `if` statement, both in simulation and synthesis
- ⚠️ Showed that adding an `else` alone doesn't prevent a latch — **every reachable condition** must resolve to an assignment
- ⚠️ Demonstrated that `case` statements infer latches the same way `if` statements do when branches are missing
- ✨ Identified **per-signal partial assignment** as a distinct failure mode — a `default` branch alone isn't enough if one signal is skipped inside it
- ✅ Verified a fully-specified `case` statement synthesizes to clean, latch-free combinational logic
- ✅ Confirmed clean synthesis behavior on standard reference designs — **MUX, DEMUX, and a ripple carry adder**

---

## 📌 Conclusion

<div align="center">

> 🎓 Across every design in this module, the pattern held without exception: Yosys could only optimize — simplify logic, share resources, map cleanly onto SKY130 cells — when the RTL left it **nothing ambiguous to resolve**. The moment an output had no assignment for some reachable condition, whether from a missing `else`, a missing `case` branch, or one signal skipped inside an otherwise-complete branch, the tool's only correct move was to insert a latch and hold state.
>
> The multiplexer, demultiplexer, and ripple carry adder confirm the other side of that same rule: **fully-specified combinational logic synthesizes exactly as clean as it reads.**
>
> **📏 Working rule:** assign every output, for every branch, for every reachable input — anything less isn't an optimization opportunity, it's a latch waiting to be inferred.

</div>
