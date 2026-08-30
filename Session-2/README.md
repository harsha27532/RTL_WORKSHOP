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

<img width="700" alt="bad_mux.v source code" src="session2_images/bad_mux_code.jpeg" />

**Figure 1:** `bad_mux.v` source.

At first glance this looks fine — both branches of the `if` are assigned, so there's no missing-`else` latch issue. The actual mistake is more subtle: it uses **non-blocking assignments (`<=`)** inside a **combinational** `always @(*)` block. Non-blocking assignments schedule their update to happen at the end of the current simulation time step rather than immediately — exactly the right behavior for sequential (clocked) logic, but inside combinational logic it introduces a one-delta-cycle lag that doesn't match what a synthesis tool will actually build.

```bash
iverilog -o bad_mux bad_mux.v tb_bad_mux.v
gtkwave bad_mux.vcd
```

<img width="700" alt="bad_mux simulation waveform" src="session2_images/bad_mux_waveform.jpeg" />

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

<img width="700" alt="good_mux synthesized schematic and netlist" src="session2_images/good_mux_netlist_schematic.jpeg" />

**Figure 3:** `good_mux` synthesized schematic and netlist.

> ✅ **Result:** The `if`/`else` structure mapped directly onto a single SKY130 `sky130_fd_sc_hd__mux2_1` cell, with `A0`, `A1`, and `S` wired to `i0`, `i1`, and `sel` respectively.

Out of curiosity, the actual `.lib` entry for this cell was opened directly to see what synthesis was choosing from — timing arcs, leakage power for every input combination, and cell area:

<img width="700" alt="sky130_fd_sc_hd__mux2_1 liberty file entry, part 1" src="session2_images/liberty_mux2_cell_1.jpeg" />

**Figure 4:** `sky130_fd_sc_hd__mux2_1` liberty entry — timing and power data (part 1).

<img width="700" alt="sky130_fd_sc_hd__mux2_1 liberty file entry, part 2" src="session2_images/liberty_mux2_cell_2.jpeg" />

**Figure 5:** `sky130_fd_sc_hd__mux2_1` liberty entry (part 2).

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

<img width="700" alt="good_counter synthesized schematic" src="session2_images/good_counter_schematic1.jpeg" />

**Figure 6:** `good_counter` synthesized schematic.

<img width="700" alt="good_counter detailed DFF schematic" src="session2_images/good_counter_dff_detail.jpeg" />

**Figure 7:** Detailed view of the counter's flip-flops.

> ✅ **Result:** The counter's two bits (`cnt[0]`, `cnt[1]`) each map onto their own `$_DFF_PP0_` flip-flop, with `sky130_fd_sc_hd__nor2_1` and `nor2b_1` cells forming the next-state logic feeding them.

<img width="700" alt="good_counter_netlist.v alongside its schematic" src="session2_images/good_counter_netlist_and_schematic.jpeg" />

**Figure 8:** Netlist and schematic shown side by side.

<img width="700" alt="good_counter_netlist.v full contents" src="session2_images/good_counter_netlist_code.jpeg" />

**Figure 9:** Full contents of `good_counter_netlist.v`.

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

<img width="700" alt="multiple_modules hierarchical schematic" src="session2_images/multiple_modules_hier.jpeg" />

**Figure 10:** Hierarchical schematic — module boundaries preserved.

> ✅ **Result:** At this level, `sub_module1` and `sub_module2` still appear as their own labeled blocks (`u1`, `u2`) in the schematic — the module boundaries from the RTL are preserved rather than merged.

### 🟧 4.2 Flattened View

```bash
flatten
show multiple_modules
```

<img width="700" alt="multiple_modules flattened schematic showing gate-level cells directly" src="session2_images/multiple_modules_flat.jpeg" />

**Figure 11:** Flattened schematic — gates exposed directly, no sub-module boundaries.

> ✨ **Insight:** After flattening, those same two blocks disappear — `u1.a`, `u1.b`, `u1.y` and `u2.a`, `u2.b`, `u2.y` now sit directly on the gates themselves (`sky130_fd_sc_hd__and2_0` and `sky130_fd_sc_hd__or2_0`), with the `$scopeinfo` markers being the only trace left of the original module names. This is the concrete difference between hierarchical and flat synthesis: same logic, same two gates either way, but the flattened netlist has no sub-module boundaries left to read.

---

## 5️⃣ BabySoC — Cloning, Exploring RVMYTH, and Pre-Synthesis Simulation

### 📥 5.1 Cloning the Repository

The second half of the day moved to a different project — **VSDBabySoC**, a small RISC-V-based SoC design:

```bash
git clone https://github.com/manili/VSDBabySoC
cd VSDBabySoC
```

<img width="700" alt="VSDBabySoC module directory listing" src="session2_images/babysoc_module_listing.jpeg" />

**Figure 12:** VSDBabySoC `module/` directory listing.

> The `module/` directory contains the SoC's building blocks: `avsddac.v` and `avsdpll.v` (analog DAC and PLL models), `clk_gate.v`, the RVMYTH core (`rvmyth.v`, `rvmyth_gen.v`, `rvmyth.tlv`), and both pre-synthesis and post-synthesis testbenches.

### 🔍 5.2 Exploring the RVMYTH Core

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

<img width="700" alt="rvmyth.v source showing module interface and instruction trace" src="session2_images/rvmyth_code.jpeg" />

**Figure 13:** `rvmyth.v` source, showing the module interface and generated instruction trace.

> ✨ **Insight:** RVMYTH is a small RISC-V core written in **TL-Verilog** and generated into plain Verilog (`rvmyth_gen.v`). The comments in the generated file trace out its instruction sequence directly — a small loop built from `ADDI`, `ADD`, `SUB`, and `BNE`/`BEQ` — which is what eventually drives the `OUT` register feeding the rest of the SoC.

### 🧪 5.3 Running the Pre-Synthesis Simulation

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

<img width="700" alt="vsdbabysoc_tb testbench source with PRE_SYNTH_SIM / POST_SYNTH_SIM switch" src="session2_images/babysoc_testbench_code.jpeg" />

**Figure 14:** Testbench source, showing the `PRE_SYNTH_SIM` / `POST_SYNTH_SIM` macro switch.

> ✨ **Insight:** The testbench uses a `PRE_SYNTH_SIM` / `POST_SYNTH_SIM` macro switch to include either the original RTL sources or the synthesized netlist plus SKY130 primitives — the same testbench works for both stages just by defining a different macro at compile time.

```bash
iverilog -DPRE_SYNTH_SIM -o pre_synth_sim.out testbench.v
vvp pre_synth_sim.out
gtkwave pre_synth_sim.vcd
```

<img width="700" alt="Pre-synthesis simulation waveform for VSDBabySoC" src="session2_images/babysoc_presynth_waveform.jpeg" />

**Figure 15:** BabySoC pre-synthesis simulation waveform.

> ✅ **Result:** The waveform shows `CLK` toggling, `RV_TO_DAC[9:0]` counting through values (`334` at the marker), and `OUT` responding as the DAC's analog approximation of that digital value rises and falls — confirming the RVMYTH core, clock gating, and DAC model are all functioning together correctly at the RTL level, before synthesis is involved at all.

---

## 🏁 Overall Result

- ⚠️ Diagnosed a synthesis-simulation risk in `bad_mux` caused by **non-blocking assignments** inside a combinational `always` block, and fixed it by switching to blocking assignments
- ✅ Ran a complete **Yosys synthesis flow** on `good_mux`, down to reading the actual `.lib` cell definition Yosys selected
- ✅ Repeated the same flow on `good_counter`, confirming each counter bit gets its own flip-flop and NOR-based next-state logic
- ⚖️ Repeated the flow again on `multiple_modules`, directly comparing **hierarchical synthesis** (module boundaries preserved) against **flattened synthesis** (module boundaries dissolved into raw gates)
- 🖥️ Cloned and explored **VSDBabySoC**, including reading through the RVMYTH RISC-V core's generated instruction trace
- ✅ Ran BabySoC's **pre-synthesis simulation** and confirmed correct RTL-level behavior across the RVMYTH core, clock gating, and DAC model before moving on to synthesis
