<div align="center">

# ⚡ Module 4 — Blocking Assignments & Synthesis-Simulation Mismatch

### *When `=` Lies to You: Tracing the Gap Between Simulation and Silicon*

<img src="https://img.shields.io/badge/Language-Verilog-9c27b0?style=for-the-badge&logo=v&logoColor=white" alt="Verilog">
<img src="https://img.shields.io/badge/Tool-Icarus%20Verilog-2196f3?style=for-the-badge&logo=icons8&logoColor=white" alt="Icarus Verilog">
<img src="https://img.shields.io/badge/Tool-GTKWave-ff9800?style=for-the-badge&logo=waveshare&logoColor=white" alt="GTKWave">
<img src="https://img.shields.io/badge/Tool-Yosys-4caf50?style=for-the-badge&logo=opensourcehardware&logoColor=white" alt="Yosys">
<img src="https://img.shields.io/badge/PDK-SKY130-e91e63?style=for-the-badge&logo=chip&logoColor=white" alt="SKY130">

<br>

<img src="https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square">
<img src="https://img.shields.io/badge/Focus-Blocking%20vs%20Non--Blocking-blueviolet?style=flat-square">
<img src="https://img.shields.io/badge/Bug%20Class-Latch%20Inference-yellow?style=flat-square">

<sub>🔗 Part of the <a href="https://github.com/ArpithaGarrepalli/RTL_Workshop"><b>RTL Workshop</b></a> series</sub>

</div>

---

## 📖 Overview

> 🟣 Whether a statement inside an `always` block uses `=` or `<=` isn't a stylistic choice — it changes **how the simulator executes that statement**, and it can change **what hardware synthesis actually builds**.

This module works through that gap directly: a multiplexer built two ways — one correct, one subtly broken — simulated and synthesized side by side, followed by a closer look at exactly how blocking assignments execute so the failure mode makes sense rather than just being a rule to memorize.

## 🎯 Objectives

> 🔀 Understand how **blocking (`=`)** and **non-blocking (`<=`)** assignments differ in execution
> 🐛 Identify what causes **synthesis-simulation mismatch** and how to spot it in a waveform
> 🎛️ Build and simulate a **multiplexer** using the ternary operator
> 🔍 Trace **blocking-assignment execution order**, statement by statement
> 🧪 Verify RTL behavior using **Icarus Verilog** and **GTKWave**
> 🔨 Synthesize designs with **Yosys** and map them onto **SKY130** standard cells
> ⚖️ Compare **simulated behavior** against **synthesized hardware** directly

<table>
<tr><td>💻 <b>Verilog HDL</b></td><td>RTL design</td></tr>
<tr><td>🧪 <b>Icarus Verilog</b></td><td>Compiling and simulating designs</td></tr>
<tr><td>📊 <b>GTKWave</b></td><td>Waveform inspection</td></tr>
<tr><td>⚡ <b>Yosys</b></td><td>RTL synthesis</td></tr>
<tr><td>📚 <b>SKY130 Standard-Cell Library</b></td><td>Technology mapping</td></tr>
<tr><td>📝 <b>gVim</b></td><td>Viewing and editing Verilog source</td></tr>
<tr><td>🐧 <b>Linux Terminal</b></td><td>Command execution</td></tr>
</table>

---

## 📑 Table of Contents

| # | Section |
|:-:|---|
| 1️⃣ | [Building and Verifying a Correct Multiplexer](#1️⃣-building-and-verifying-a-correct-multiplexer) |
| 2️⃣ | [Diagnosing a Broken Multiplexer](#2️⃣-diagnosing-a-broken-multiplexer) |
| 3️⃣ | [Understanding Blocking Assignment Execution](#3️⃣-understanding-blocking-assignment-execution) |
| 4️⃣ | [Results at a Glance](#4️⃣-results-at-a-glance) |
| 🏁 | [Overall Result](#-overall-result) |
| 📌 | [Conclusion](#-conclusion) |

---

## 1️⃣ Building and Verifying a Correct Multiplexer

### 🧪 1.1 Simulating the Ternary MUX

A 2:1 multiplexer written as a single ternary expression is about as close to unambiguous combinational logic as Verilog gets — there's no branch that can be left unspecified.

```bash
iverilog -o mux ternary_operator_mux.v tb_ternary_operator_mux.v
gtkwave ternary_operator_mux.vcd
```

<img width="1600" height="850" alt="4_1" src="https://github.com/user-attachments/assets/ea36282b-423c-4311-85be-1af8fff22f76" />

**Figure 1:** Ternary MUX simulation waveform.

> ✅ **Result:** The output tracks the selected input cleanly, confirming the RTL behaves as intended before synthesis even enters the picture.

### ⚡ 1.2 Mapping the MUX to Silicon

The same design was pushed through Yosys and mapped onto the SKY130 library to see what hardware it actually resolves to.

```bash
yosys
read_verilog mux_generate.v
synth -top mux_generate
abc -liberty ../lib/sky130_fd_sc_hd__tt_025C_1v80.lib
show
```

<img width="1600" height="850" alt="4_2" src="https://github.com/user-attachments/assets/fe170c20-cb18-4a71-8b01-befc902c0f68" />


**Figure 2:** Synthesized gate-level representation of the ternary MUX.

> ✨ **Insight:** Yosys mapped the design directly onto a **single SKY130 multiplexer cell** — no extra logic, no latch, exactly what a fully-specified ternary expression should produce.

### 🔁 1.3 Confirming Behavior Across Inputs

To rule out the possibility that the first simulation just got lucky with its test vectors, the design was re-run against a wider set of input/select combinations.

```bash
iverilog -o mux mux_generate.v tb_mux_generate.v
gtkwave mux_generate.vcd
```

 <img width="973" height="922" alt="Screenshot 2026-08-22 210559" src="https://github.com/user-attachments/assets/c3909d81-5e7f-425b-837b-dd838d1a8eb2" />


**Figure 3:** MUX behavior verified across a wider set of input/select combinations.

> ✅ **Result:** Every combination tested tracked correctly, confirming the baseline this module compares everything else against.

---

## 2️⃣ Diagnosing a Broken Multiplexer

### ⚠️ 2.1 First Signs of Trouble

A second multiplexer was written with an **incomplete `always` block** — the kind of gap that's easy to miss reading through the code, but that a simulator and a synthesis tool won't handle the same way.

```bash
iverilog -o bad_mux bad_mux.v tb_bad_mux.v
gtkwave bad_mux.vcd
```

<img width="1727" height="920" alt="Screenshot 2026-08-22 210358" src="https://github.com/user-attachments/assets/1a784202-80db-4481-9460-7694ce7f948f" />


**Figure 4:** Faulty MUX waveform — output no longer follows the select signal cleanly.

> ⚠️ **Result:** This is the first visible sign that this RTL won't synthesize into what it appears to describe.

### 🔬 2.2 Tracing the Latch

Looking more closely at exactly *when* the output fails to update reveals the underlying cause.

<img width="958" height="930" alt="Latch inference detail" src="https://github.com/user-attachments/assets/6be89683-4f14-4a27-81c9-e4a7ef19417a" />

**Figure 5:** Close-up trace showing the output freezing at its previous value.

> ✨ **Insight:** The output **freezes at its previous value** exactly where an assignment was skipped in the RTL — the signature of **latch inference**. During synthesis, this incomplete `always` block resolves into a MUX plus an unintended latch, so the hardware won't behave identically to what the RTL seemed to promise.

> ⚠️ **Result:** This is synthesis-simulation mismatch, caught here in simulation before it ever reached actual hardware.

---

## 3️⃣ Understanding Blocking Assignment Execution

### 🧪 3.1 Watching Execution Order in Simulation

Stepping away from the MUX examples, a standalone design isolates how blocking assignments actually execute, statement by statement.

```bash
iverilog -o blocking blocking_caveat.v tb_blocking_caveat.v
gtkwave blocking_caveat.vcd
```

<img width="948" height="927" alt="Screenshot 2026-08-22 210938" src="https://github.com/user-attachments/assets/7e18e811-67c3-4fa0-acbb-c6dc4fb00414" />


**Figure 6:** Waveform tracing sequential execution of blocking assignments.

> ✨ **Insight:** Each `=` takes effect **the instant it executes**, and every line after it sees that new value immediately. This sequential, no-delay execution is exactly why blocking assignments suit combinational logic — and exactly why they're risky inside a sequential block, where later logic often needs to see the *old* register value rather than one just written earlier in the same clock cycle.

### ⚡ 3.2 Confirming the Synthesized Result

The same blocking-assignment design was synthesized to check whether the hardware Yosys builds actually matches what the simulation predicted.

```bash
yosys
read_verilog blocking_caveat.v
synth -top blocking_caveat
abc -liberty ../lib/sky130_fd_sc_hd__tt_025C_1v80.lib
show
```

<img width="966" height="909" alt="Screenshot 2026-08-22 210959" src="https://github.com/user-attachments/assets/c24a2dfd-ddda-4a50-987f-4a25120a2687" />


**Figure 7:** Synthesized SKY130-mapped circuit for the blocking-assignment design.

> ✅ **Result:** The synthesized circuit matches the simulated behavior — confirming that blocking assignments synthesize predictably as long as the logic they describe stays **combinational and fully specified**.

### 🔗 3.3 Same-Block Value Dependency

One more pass over the same waveform, this time tracking a signal whose value depends on something assigned earlier in the *same* procedural block, on the *same* simulation time step.

```bash
iverilog -o blocking_past blocking_caveat.v tb_blocking_caveat.v
gtkwave blocking_caveat.vcd
```

<img width="959" height="915" alt="Screenshot 2026-08-22 211018" src="https://github.com/user-attachments/assets/1a6c4a4c-c544-45ef-aa78-5db83e982cc3" />


**Figure 8:** Later statement picking up a value written earlier in the same block.

> ✨ **Insight:** The later statement picks up the value its predecessor **just wrote**, not whatever value existed before the block started running. This is the underlying mechanism behind why statement order matters so much with `=`, and it's exactly the behavior that makes blocking assignments a poor fit inside sequential `always` blocks, where the old register value is usually what's actually needed.

---

## 4️⃣ Results at a Glance

<div align="center">

| # | What Was Tested | Result | Takeaway |
|:-:|---|:---:|---|
| 1.1 | Ternary MUX simulation | ✅ | Clean combinational reference behavior |
| 1.2 | Ternary MUX synthesis | ✅ | Maps directly to a SKY130 MUX cell |
| 1.3 | MUX stress test | ✅ | Baseline holds across all input combinations |
| 2.1 | Faulty MUX, first look | ⚠️ | Output stops tracking select signal correctly |
| 2.2 | Faulty MUX, confirmed | ⚠️ | Latch-inference fingerprint identified |
| 3.1 | Blocking assignment sim | ℹ️ | Sequential, immediate-update execution confirmed |
| 3.2 | Blocking assignment synthesis | ✅ | Synthesized circuit matches simulated intent |
| 3.3 | Blocking + same-block value | ℹ️ | Later statements see freshly-updated values, not old ones |

</div>

---

## 🏁 Overall Result

- ✅ Verified a correctly-written **ternary MUX** simulates and synthesizes identically, mapping to a single SKY130 cell
- ✅ Reproduced **synthesis-simulation mismatch** directly by leaving an `always` block incomplete, and watched it manifest as latch inference
- ✅ Confirmed **blocking assignments** update — and get read — immediately, in exact statement order
- ✅ Verified that fully-specified, combinational blocking-assignment logic **synthesizes predictably**

---

## 📌 Conclusion

<div align="center">

> 🎓 The two multiplexers in this module are nearly identical on paper. Only one survives synthesis with its intended behavior intact — and the difference was never really about `=` versus `<=` in isolation. It came down to whether **every output was fully specified for every input condition**, and whether the designer accounted for blocking assignments executing immediately, in the order they're written.
>
> That's the connective thread between Sections 2 and 3: the same immediate, in-order execution that makes blocking assignments predictable in combinational logic is exactly what makes them risky the moment they end up in a clocked, sequential context. Mismatch isn't a mysterious tool quirk — it's a direct, traceable consequence of incomplete or order-sensitive RTL.
>
> **📏 Working rule:** blocking (`=`) for combinational `always` blocks, non-blocking (`<=`) for sequential ones — and treat any unassigned branch as a latch waiting to happen.

</div>
