<div align="center">

# ⚡ Session 2 — Hunting a MUX Bug, Yosys Synthesis in Practice, and BabySoC's First Simulation

### *Tracing a One-Character Slip All the Way to a Full RISC-V SoC Run*

<img src="https://img.shields.io/badge/Language-Verilog-9c27b0?style=for-the-badge&logo=v&logoColor=white" alt="Verilog">
<img src="https://img.shields.io/badge/Tool-Icarus%20Verilog-2196f3?style=for-the-badge&logo=icons8&logoColor=white" alt="Icarus Verilog">
<img src="https://img.shields.io/badge/Tool-GTKWave-ff9800?style=for-the-badge&logo=waveshare&logoColor=white" alt="GTKWave">
<img src="https://img.shields.io/badge/Tool-Yosys-4caf50?style=for-the-badge&logo=opensourcehardware&logoColor=white" alt="Yosys">
<img src="https://img.shields.io/badge/PDK-SKY130-e91e63?style=for-the-badge&logo=chip&logoColor=white" alt="SKY130">

<br>

<img src="https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square">
<img src="https://img.shields.io/badge/Bug%20Class-Blocking%20vs%20Non--Blocking-yellow?style=flat-square">
<img src="https://img.shields.io/badge/Featured-VSDBabySoC-blueviolet?style=flat-square">

<sub>🔗 Part of the <a href="https://github.com/ArpithaGarrepalli/RTL_Workshop"><b>RTL Workshop</b></a> series</sub>

</div>

---

## 📖 Overview

> 🟣 This session opened with a debugging exercise — a MUX that looked reasonable at a glance but had a subtle coding mistake, uncovered by comparing simulation behavior against what the code actually says. Once fixed, that same MUX became the reference example for a full **Yosys synthesis walkthrough**, repeated afterward on a counter and a multi-module design to compare hierarchical and flattened synthesis results.

The second half of the day shifted to a different project entirely — cloning and exploring **VSDBabySoC**, then running its pre-synthesis simulation.

<table>
<tr><td>🛠️ <b>Tools used</b></td><td>Icarus Verilog, GTKWave, Yosys</td></tr>
<tr><td>🧩 <b>Example designs</b></td><td><code>bad_mux</code>, <code>good_mux</code>, <code>good_counter</code>, <code>multiple_modules</code>, VSDBabySoC</td></tr>
<tr><td>📋 <b>Prerequisites</b></td><td>Basic familiarity with digital logic and the Linux terminal</td></tr>
</table>

## 🎯 Objectives

> 🐛 Diagnose a **synthesis-simulation risk** hiding in a seemingly correct MUX
> 🔨 Run a complete **Yosys synthesis flow**, down to the exact standard-cell chosen
> 🔢 Confirm counter bits map to independent **flip-flops and next-state logic**
> ⚖️ Compare **hierarchical vs. flattened** synthesis on a multi-module design
> 🖥️ Clone and explore **VSDBabySoC**, including its RISC-V core
> 🧪 Run BabySoC's **pre-synthesis simulation** and verify RTL-level behavior

---

## 📑 Table of Contents

| # | Section |
|:-:|---|
| 1️⃣ | [Debugging bad_mux](#1️⃣-debugging-bad_mux) |
| 2️⃣ | [Yosys Synthesis of good_mux](#2️⃣-yosys-synthesis-of-good_mux) |
| 3️⃣ | [Applying the Same Flow to good_counter](#3️⃣-applying-the-same-flow-to-good_counter) |
| 4️⃣ | [Applying the Same Flow to multiple_modules](#4️⃣-applying-the-same-flow-to-multiple_modules) |
| 5️⃣ | [BabySoC — Cloning, Exploring RVMYTH, and Pre-Synthesis Simulation](#5️⃣-babysoc--cloning-exploring-rvmyth-and-pre-synthesis-simulation) |
| 🏁 | [Overall Result](#-overall-result) |

---

## 1️⃣ Debugging `bad_mux`

### 🔴 1.1 Spotting the Mistake

```verilog
module bad_mux (input i0 , input i1 , input sel , output reg y);
always @ (*)
begin
	if(sel)
		y <= i1;
	else
		y <= i0;
end
endmodule
```

<img width="625" height="502" alt="Screenshot 2026-08-30 233620" src="https://github.com/user-attachments/assets/2ecf1600-a9f4-4d56-a227-960b559c5781" />


**Figure 1:** `bad_mux.v` source.

At first glance this looks fine — both branches of the `if` are assigned, so there's no missing-`else` latch issue. The actual mistake is more subtle: it uses **non-blocking assignments (`<=`)** inside a **combinational** `always @(*)` block. Non-blocking assignments schedule their update to happen at the end of the current simulation time step rather than immediately — exactly the right behavior for sequential (clocked) logic, but inside combinational logic it introduces a one-delta-cycle lag that doesn't match what a synthesis tool will actually build.

```bash
iverilog -o bad_mux bad_mux.v tb_bad_mux.v
gtkwave bad_mux.vcd
```

<img width="385" height="612" alt="Screenshot 2026-08-30 233604" src="https://github.com/user-attachments/assets/52323c47-d0ec-484a-823a-0d6c05cbcbf6" />


**Figure 2:** `bad_mux` simulation waveform.

> ⚠️ **Result:** The waveform (`i0=1`, `i1=0`, `sel=0`, `y=0`) shows the output lagging behind what the select and data lines say it should be at that instant — the visible symptom of using `<=` where `=` belongs.

### 🟢 1.2 The Fix

```verilog
module good_mux (input i0 , input i1 , input sel , output reg y);
always @ (*)
begin
	if(sel)
		y = i1;
	else
		y = i0;
end
endmodule
```

> ✨ **Insight:** Swapping `<=` for `=` is the entire fix. Blocking assignments execute immediately and are read immediately by whatever comes next in the same block — the correct behavior for combinational logic, where there's no clock edge to wait for.

---

## 2️⃣ Yosys Synthesis of `good_mux`

With the corrected `good_mux` design in hand, this became the reference walkthrough for the rest of the day's synthesis work:

```bash
yosys
read_verilog good_mux.v
synth -top good_mux
abc -liberty sky130_fd_sc_hd__tt_025C_1v80.lib
show
write_verilog good_mux_net.v
```
<img width="1308" height="667" alt="Screenshot 2026-08-30 233651" src="https://github.com/user-attachments/assets/d31c7d83-f97c-4ecd-9e29-9df71bfc2669" />

**Figure 3:** `good_mux` synthesized schematic and netlist.

> ✅ **Result:** The `if`/`else` structure mapped directly onto a single SKY130 `sky130_fd_sc_hd__mux2_1` cell, with `A0`, `A1`, and `S` wired to `i0`, `i1`, and `sel` respectively.

Out of curiosity, the actual `.lib` entry for this cell was opened directly to see what synthesis was choosing from — timing arcs, leakage power for every input combination, and cell area:

<img width="393" height="557" alt="Screenshot 2026-08-30 233711" src="https://github.com/user-attachments/assets/5c1a5fdb-454c-45b4-bce3-87324edc733e" />


**Figure 4:** `sky130_fd_sc_hd__mux2_1` liberty entry — timing and power data (part 1).

> ✨ **Insight:** This is the same `sky130_fd_sc_hd__mux2_1` definition Yosys picked in the schematic above — seeing the raw `.lib` entry makes it clear synthesis isn't picking cells arbitrarily; every leakage-power value, area, and timing arc is fully characterized ahead of time.

---

## 3️⃣ Applying the Same Flow to `good_counter`

The identical compile → synthesize → inspect flow was repeated on a counter design:

```bash
yosys
read_verilog good_counter.v
synth -top good_counter
abc -liberty sky130_fd_sc_hd__tt_025C_1v80.lib
show
write_verilog -noattr good_counter_netlist.v
```

<img width="962" height="188" alt="Screenshot 2026-08-30 233816" src="https://github.com/user-attachments/assets/fc54481e-3902-48d2-9e36-33f3f816ae42" />


**Figure 5:** `good_counter` synthesized schematic.

<img width="1047" height="312" alt="Screenshot 2026-08-30 233854" src="https://github.com/user-attachments/assets/13cc934b-5ea9-41a9-843f-429cd4b7e229" />


**Figure 6:** Detailed view of the counter's flip-flops.

> ✅ **Result:** The counter's two bits (`cnt[0]`, `cnt[1]`) each map onto their own `$_DFF_PP0_` flip-flop, with `sky130_fd_sc_hd__nor2_1` and `nor2b_1` cells forming the next-state logic feeding them.

<img width="1667" height="832" alt="Screenshot 2026-08-31 001307" src="https://github.com/user-attachments/assets/f9aaa0ad-1b9c-450d-aff3-0467cc87d01e" />

**Figure 7:** Netlist and schematic shown side by side.


> ✨ **Insight:** Reading the generated netlist directly confirms what the schematic shows: two separate `always @(posedge clk, posedge reset)` blocks, one per bit of `cnt`, each driven by its own NOR-based next-state logic rather than one shared 2-bit register update.

---

## 4️⃣ Applying the Same Flow to `multiple_modules`

Repeating the flow once more on a multi-module design (`sub_module1` = AND, `sub_module2` = OR, wired together as `multiple_modules`) surfaced a clear difference depending on whether the design is synthesized hierarchically or flattened first.

### 🟦 4.1 Hierarchical View

```bash
read_verilog multiple_modules.v
synth -top multiple_modules
show multiple_modules
```

<img width="337" height="85" alt="Screenshot 2026-08-30 233903" src="https://github.com/user-attachments/assets/ba741134-f30a-4108-9088-07dae4bf7a7e" />

**Figure 8:** Hierarchical schematic — module boundaries preserved.

> ✅ **Result:** At this level, `sub_module1` and `sub_module2` still appear as their own labeled blocks (`u1`, `u2`) in the schematic — the module boundaries from the RTL are preserved rather than merged.

### 🟧 4.2 Flattened View

```bash
flatten
show multiple_modules
```

<img width="1000" height="172" alt="Screenshot 2026-08-30 233912" src="https://github.com/user-attachments/assets/627c2b18-3926-4f5b-8eae-2de21bbd2c3a" />


**Figure 9:** Flattened schematic — gates exposed directly, no sub-module boundaries.

> ✨ **Insight:** After flattening, those same two blocks disappear — `u1.a`, `u1.b`, `u1.y` and `u2.a`, `u2.b`, `u2.y` now sit directly on the gates themselves (`sky130_fd_sc_hd__and2_0` and `sky130_fd_sc_hd__or2_0`), with the `$scopeinfo` markers being the only trace left of the original module names. This is the concrete difference between hierarchical and flat synthesis: same logic, same two gates either way, but the flattened netlist has no sub-module boundaries left to read.

---

## 5️⃣ BabySoC — Cloning, Exploring RVMYTH, and Pre-Synthesis Simulation

### 🔍 5.1 Exploring the RVMYTH Core

```verilog
// Custom module interface for BabySoC.
module rvmyth(
    output reg [9:0] OUT,
    input CLK,
    input reset
);
wire clk = CLK;

`include "rvmyth_gen.v" //_\TLV
```

<img width="462" height="626" alt="Screenshot 2026-08-30 233932" src="https://github.com/user-attachments/assets/d43b4d26-b5bb-48ed-ba3c-d32c0a87a3b4" />


**Figure 10:** `rvmyth.v` source, showing the module interface and generated instruction trace.

> ✨ **Insight:** RVMYTH is a small RISC-V core written in **TL-Verilog** and generated into plain Verilog (`rvmyth_gen.v`). The comments in the generated file trace out its instruction sequence directly — a small loop built from `ADDI`, `ADD`, `SUB`, and `BNE`/`BEQ` — which is what eventually drives the `OUT` register feeding the rest of the SoC.

### 🧪 5.2 Running the Pre-Synthesis Simulation

```verilog
`ifdef PRE_SYNTH_SIM
    `include "vsdbabysoc.v"
    `include "avsddac.v"
    `include "avsdpll.v"
    `include "rvmyth.v"
    `include "clk_gate.v"
`elsif POST_SYNTH_SIM
    `include "vsdbabysoc.synth.v"
    `include "avsddac.v"
    `include "avsdpll.v"
    `include "primitives.v"
    `include "sky130_fd_sc_hd.v"
`endif

module vsdbabysoc_tb;
    reg reset;
    reg VCO_IN;
    reg ENb_CP;
    reg ENb_VCO;
    reg REF;
    reg real VREFL;
    reg real VREFH;
    wire real OUT;
    ...
    initial begin
        reset = 0;
        VREFL = 0.0;
        VREFH = 3.3;
        {REF, ENb_VCO} = 0;
        VCO_IN = 1'b0;

        #20 reset = 1;
        #100 reset = 0;
    end
```

<img width="396" height="658" alt="Screenshot 2026-08-30 233950" src="https://github.com/user-attachments/assets/b6f5e2e1-c47c-4b3c-a2aa-162766aa9ce5" />


**Figure 11:** Testbench source, showing the `PRE_SYNTH_SIM` / `POST_SYNTH_SIM` macro switch.

> ✨ **Insight:** The testbench uses a `PRE_SYNTH_SIM` / `POST_SYNTH_SIM` macro switch to include either the original RTL sources or the synthesized netlist plus SKY130 primitives — the same testbench works for both stages just by defining a different macro at compile time.

```bash
iverilog -DPRE_SYNTH_SIM -o pre_synth_sim.out testbench.v
vvp pre_synth_sim.out
gtkwave pre_synth_sim.vcd
```

<img width="1261" height="616" alt="Screenshot 2026-08-30 234005" src="https://github.com/user-attachments/assets/3e953d26-61ba-41ed-bebd-eb29242fd0b4" />


**Figure 12:** BabySoC pre-synthesis simulation waveform.

> ✅ **Result:** The waveform shows `CLK` toggling, `RV_TO_DAC[9:0]` counting through values (`334` at the marker), and `OUT` responding as the DAC's analog approximation of that digital value rises and falls — confirming the RVMYTH core, clock gating, and DAC model are all functioning together correctly at the RTL level, before synthesis is involved at all.

---

## 🏁 Overall Result

- ⚠️ Diagnosed a synthesis-simulation risk in `bad_mux` caused by **non-blocking assignments** inside a combinational `always` block, and fixed it by switching to blocking assignments
- ✅ Ran a complete **Yosys synthesis flow** on `good_mux`, down to reading the actual `.lib` cell definition Yosys selected
- ✅ Repeated the same flow on `good_counter`, confirming each counter bit gets its own flip-flop and NOR-based next-state logic
- ⚖️ Repeated the flow again on `multiple_modules`, directly comparing **hierarchical synthesis** (module boundaries preserved) against **flattened synthesis** (module boundaries dissolved into raw gates)
- 🖥️ Cloned and explored **VSDBabySoC**, including reading through the RVMYTH RISC-V core's generated instruction trace
- ✅ Ran BabySoC's **pre-synthesis simulation** and confirmed correct RTL-level behavior across the RVMYTH core, clock gating, and DAC model before moving on to synthesis
