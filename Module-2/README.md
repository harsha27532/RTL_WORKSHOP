<div align="center">
# ⚡ Module 2 — Timing Libraries, Synthesis Approaches & Flip-Flop Coding
 
### *From Standard Cells to Silicon: Mastering the RTL-to-Gates Journey*
 
<img src="https://img.shields.io/badge/Language-Verilog-9c27b0?style=for-the-badge&logo=v&logoColor=white" alt="Verilog">
<img src="https://img.shields.io/badge/Tool-Icarus%20Verilog-2196f3?style=for-the-badge&logo=icons8&logoColor=white" alt="Icarus Verilog">
<img src="https://img.shields.io/badge/Tool-GTKWave-ff9800?style=for-the-badge&logo=waveshare&logoColor=white" alt="GTKWave">
<img src="https://img.shields.io/badge/Tool-Yosys-4caf50?style=for-the-badge&logo=opensourcehardware&logoColor=white" alt="Yosys">
<img src="https://img.shields.io/badge/PDK-SKY130-e91e63?style=for-the-badge&logo=chip&logoColor=white" alt="SKY130">
<br>
<img src="https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square">
<img src="https://img.shields.io/badge/Node-130nm-blueviolet?style=flat-square">
<img src="https://img.shields.io/badge/Voltage-1.8V-yellow?style=flat-square">
<sub>🔗 Part of the <a href="https://github.com/ArpithaGarrepalli/RTL_Workshop"><b>RTL Workshop</b></a> series</sub>
 
</div>
---
 
## 🎯 Objectives
 
> 🧠 Understand **timing libraries** and the **SKY130 PDK**
> 🏗️ Explore **hierarchical vs. flattened synthesis**
> 🎛️ Study different **flip-flop coding styles**
> 🔄 Walk through the complete **RTL simulation and synthesis flow**
> ✨ Observe how **Yosys optimizes RTL** into efficient gate-level hardware
 
<table>
<tr><td>🛠️ <b>Tools used</b></td><td>Icarus Verilog · GTKWave · Yosys</td></tr>
<tr><td>📚 <b>PDK</b></td><td><code>sky130_fd_sc_hd__tt_025C_1v80.lib</code></td></tr>
<tr><td>🧩 <b>Example designs</b></td><td>D flip-flops (async reset/set, sync reset), <code>mul2</code>, <code>mult8</code></td></tr>
</table>
---
 
## 📑 Table of Contents
 
| # | Section | Highlight |
|:-:|---|---|
| 1️⃣ | [Timing Libraries](#1️⃣-timing-libraries) | 🟢 Process, voltage & temperature corners |
| 2️⃣ | [Hierarchical and Flattened Synthesis](#2️⃣-hierarchical-and-flattened-synthesis) | 🏗️ Two synthesis philosophies |
| 3️⃣ | [Flip-Flop Coding Styles](#3️⃣-flip-flop-coding-styles) | 🎛️ Async reset/set vs. sync reset |
| 4️⃣ | [RTL Simulation and Synthesis Flow](#4️⃣-rtl-simulation-and-synthesis-flow) | 🔄 Sim → Synth → Map |
| 5️⃣ | [Interesting Optimization](#5️⃣-interesting-optimization) | ✨ Multiplication → pure wiring |
| 🏁 | [Overall Result](#-overall-result) | ✅ Summary checklist |
| 📌 | [Conclusion](#-conclusion) | 🎓 Takeaways |
 
---
 
## 1️⃣ Timing Libraries
 
### 📘 1.1 The SKY130 PDK
 
> 🟣 The **SKY130 PDK** packages the technology data and standard-cell libraries needed to design and synthesize digital circuits on **130 nm CMOS technology**.
 
The timing library used throughout this workshop:
 
```text
sky130_fd_sc_hd__tt_025C_1v80.lib
```
 
### 🔍 1.2 Decoding `tt_025C_1v80`
 
<div align="center">
| Token | 🎯 Meaning | 📊 Detail |
|:---:|:---|:---|
| 🟢 `tt` | Typical process corner | Neither best- nor worst-case silicon |
| 🌡️ `025C` | Temperature | 25 °C operating condition |
| ⚡ `1v80` | Supply voltage | 1.8 V |
 
</div>
### 📂 1.3 Exploring the `.lib` File
 
The `.lib` file holds everything the synthesizer needs about each standard cell — **timing arcs, power figures, and the operating conditions** they were characterized under.
 
<p align="center">
<img width="800" alt="SKY130 timing library file" src="https://github.com/user-attachments/assets/ff0007e7-02cf-4d85-9d2e-5e1e4330d753" />
</p>
**Figure 1:** SKY130 timing library file.
 
> ✅ **Result:** The SKY130 timing library opened cleanly, and its library and operating-condition metadata were reviewed.
 
---
 
## 2️⃣ Hierarchical and Flattened Synthesis
 
### 🗂️ 2.1 Hierarchical Synthesis 🟦
 
Hierarchical synthesis **preserves the original module boundaries** of the RTL. Each module stays distinct — great for readability, organization, and debugging.
 
<img width="1912" height="997" alt="Hierarchical synthesized design" src="https://github.com/user-attachments/assets/24d239bb-1302-4cf2-8e9d-dac04aaadbe2" />
**Figure 2:** Hierarchical synthesized design.
 
> ✅ **Result:** The multi-module design retained its original structure and inter-module connections after synthesis.
 
### 🌐 2.2 Flattened Synthesis 🟧
 
Flattened synthesis **merges every module into one flat design**, unlocking optimization opportunities that cross module boundaries.
 
```text
flatten
```
 
<img width="1907" height="1007" alt="Flattened synthesized design" src="https://github.com/user-attachments/assets/1d5ee905-e098-42fb-b27d-4e2416dcad49" />
**Figure 3:** Flattened synthesized design.
 
### ⚖️ 2.3 Side-by-Side Comparison
 
<table>
<tr><th>🧩 Feature</th><th>🟦 Hierarchical</th><th>🟧 Flattened</th></tr>
<tr><td>Module structure</td><td>✅ Preserved</td><td>❌ Removed</td></tr>
<tr><td>Optimization scope</td><td>⚠️ Limited between modules</td><td>🚀 Whole-design</td></tr>
<tr><td>Debuggability</td><td>😌 Easier</td><td>😅 Harder</td></tr>
<tr><td>Resulting structure</td><td>Modular</td><td>Single flat block</td></tr>
</table>
> ✅ **Result:** The trade-offs between hierarchical and flattened synthesis were clearly observed — module structure vs. optimization freedom vs. debuggability.
 
---
 
## 3️⃣ Flip-Flop Coding Styles
 
Flip-flops store binary state and form the backbone of sequential logic. Three coding styles were explored below.
 
### 🔴 3.1 Asynchronous Reset D Flip-Flop
 
An **async reset** slams the output to `0` the instant reset asserts — no clock edge required.
 
```verilog
module dff_asyncres (
    input clk,
    input async_reset,
    input d,
    output reg q
);
 
always @(posedge clk, posedge async_reset)
    if (async_reset)
        q <= 1'b0;
    else
        q <= d;
 
endmodule
```
 
**⚙️ Behavior:** `async_reset` high → `q = 0` immediately. Otherwise, `d` latches into `q` on the rising edge of `clk`.
 
```bash
iverilog dff_asyncres.v tb_dff_asyncres.v
./a.out
gtkwave tb_dff_asyncres.vcd
```
 
<img width="1917" height="982" alt="Async-reset DFF waveform" src="https://github.com/user-attachments/assets/3f0465b2-b915-429c-a83b-3a5db8275f5c" />
**Figure 4:** Simulation waveform of the asynchronous-reset D flip-flop.
 
> ✅ **Result:** Waveform confirms correct clock/reset/input/output relationships for the async-reset flip-flop.
 
### 🟢 3.2 Asynchronous Set D Flip-Flop
 
An **async set** forces `q` to `1` the moment set asserts — again, independent of the clock.
 
```verilog
module dff_async_set (
    input clk,
    input async_set,
    input d,
    output reg q
);
 
always @(posedge clk, posedge async_set)
    if (async_set)
        q <= 1'b1;
    else
        q <= d;
 
endmodule
```
 
**⚙️ Behavior:** `async_set` high → `q = 1` immediately. Otherwise, `d` is captured on the rising `clk` edge.
 
<p align="center">
<img width="500" alt="Async-set DFF waveform" src="https://github.com/user-attachments/assets/0429b814-9eb7-4415-9d54-3361713e12cd" />
</p>
**Figure 5:** Simulation waveform of the asynchronous-set D flip-flop.
 
> ✅ **Result:** The async-set flip-flop's behavior was verified through simulation.
 
### 🔵 3.3 Synchronous Reset D Flip-Flop
 
A **sync reset** only takes effect **on the active clock edge** — clean and predictable timing.
 
```verilog
module dff_syncres (
    input clk,
    input async_reset,
    input sync_reset,
    input d,
    output reg q
);
 
always @(posedge clk)
    if (sync_reset)
        q <= 1'b0;
    else
        q <= d;
 
endmodule
```
 
**⚙️ Behavior:** `sync_reset` high at the rising edge → `q = 0`. Otherwise, `d` transfers to `q`.
 
<img width="1917" height="1012" alt="Sync-reset DFF waveform" src="https://github.com/user-attachments/assets/108eda0b-bbb8-4aef-b4cd-3bd725bd28e9" />
**Figure 6:** Simulation waveform of the synchronous-reset D flip-flop.
 
> ✅ **Result:** The sync-reset flip-flop's waveform confirmed edge-aligned reset behavior.
 
---
 
## 4️⃣ RTL Simulation and Synthesis Flow
 
<div align="center">
**RTL** 📝 → **Simulate** 🧪 → **Synthesize** ⚡ → **Technology Map** 🗺️ → **Gate-Level Netlist** 🔧
 
</div>
### 🧪 4.1 Simulation with Icarus Verilog
 
```bash
iverilog dff_asyncres.v tb_dff_asyncres.v
./a.out
gtkwave tb_dff_asyncres.vcd
```
 
> ✅ **Result:** Simulation completed successfully; GTKWave confirmed correct clock/reset/input/output relationships.
 
### ⚡ 4.2 Synthesis with Yosys
 
<details>
<summary>📜 <b>Click to expand: Full Yosys command sequence</b></summary>
```text
yosys
read_liberty -lib /address/to/your/sky130/file/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog /path/to/dff_asyncres.v
synth -top dff_asyncres
dfflibmap -liberty /address/to/your/sky130/file/sky130_fd_sc_hd__tt_025C_1v80.lib
abc -liberty /address/to/your/sky130/file/sky130_fd_sc_hd__tt_025C_1v80.lib
show
```
 
</details>
<img width="1917" height="992" alt="Synthesized gate-level representation" src="https://github.com/user-attachments/assets/846ab85b-c601-4239-ab1d-ed1b0309c3f1" />
**Figure 7:** Synthesized gate-level representation.
 
Also synthesized and mapped using the full flip-flop flow:
 
<p align="center">
<img width="800" alt="Flip-flop synthesized gate-level view" src="https://github.com/user-attachments/assets/567ea919-704c-48f4-92c0-6835be3f2f9a" />
<img width="700" alt="Flip-flop synthesized gate-level detail" src="https://github.com/user-attachments/assets/e829b4a2-7a52-4a02-9e21-2b5da865fb70" />
</p>
**Figure 8:** Synthesized gate-level representation of the flip-flop design.
 
> ✅ **Result:** RTL was successfully synthesized and mapped to SKY130 standard cells; the flip-flop netlist was viewed directly in Yosys.
 
---
 
## 5️⃣ Interesting Optimization ✨
 
Synthesis tools don't just translate RTL — they **optimize** it. Here's how Yosys collapses constant multiplication into near-zero-cost hardware.
 
### ✖️ 5.1 `mul2` — Multiply by 2
 
```verilog
module mul2 (
    input [2:0] a,
    output [3:0] y
);
 
assign y = a * 2;
 
endmodule
```
 
```text
yosys
read_verilog mul2.v
prep -top mul2
abc -liberty ../lib/sky130_fd_sc_hd__tt_025C_1v80.lib
show
write_verilog -noattr mul2_net.v
gvim mul2_net.v
```
 
<img width="1910" height="1021" alt="mul2 synthesis result" src="https://github.com/user-attachments/assets/db5c19fa-8e02-462d-b07e-97e9cdd2852c" />
**Figure 9:** Yosys synthesis and optimization result for `mul2`.
 
> ✨ **Insight:** Multiplying by 2 is just a **left shift** — Yosys realizes this and eliminates multiplier hardware entirely, replacing it with pure wiring.
 
> ✅ **Result:** `mul2` synthesized down to wiring-only logic, confirmed in the generated netlist.
 
### ✖️ 5.2 `mult8` — Multiply by 9
 
```verilog
module mult8 (
    input [2:0] a,
    output [5:0] y
);
 
assign y = a * 9;
 
endmodule
```
 
```text
yosys
read_verilog mult8.v
prep -top mult8
abc -liberty ../lib/sky130_fd_sc_hd__tt_025C_1v80.lib
show
write_verilog -noattr mult8_net.v
gvim mult8_net.v
```
 
<img width="1912" height="1015" alt="mult8 synthesis result" src="https://github.com/user-attachments/assets/61ae3bea-16f5-46ee-a095-562d9be30c19" />
**Figure 10:** Yosys synthesis and optimization result for `mult8`.
 
> ✨ **Insight:** Since `9 = 8 + 1`, `a * 9` reduces to `(a << 3) + a` — a shift-and-add pattern implemented with minimal logic instead of a full multiplier.
 
> ✅ **Result:** `mult8` was optimized into efficient shift-and-add hardware, visible in the synthesized netlist.
 
### 📄 5.3 Generated Netlists
 
```text
write_verilog -noattr mul2_net.v
write_verilog -noattr mult8_net.v
gvim mul2_net.v
gvim mult8_net.v
```
 
<p align="center">
<img width="800" alt="Generated synthesized netlist" src="https://github.com/user-attachments/assets/38ec40fb-813f-444a-9e2c-0501a0047cd4" />
</p>
**Figure 11:** Generated synthesized Verilog netlist.
 
> ✅ **Result:** Both netlists were generated and reviewed, clearly showing RTL-to-gates transformation and Yosys's constant-multiplication optimizations.
 
---
 
## 🏁 Overall Result
 
- ✅ Explored the **SKY130 timing library** and its operating conditions
- ✅ Compared **hierarchical vs. flattened synthesis** approaches
- ✅ Implemented and verified **three D flip-flop coding styles** (async reset, async set, sync reset)
- ✅ Simulated RTL designs using **Icarus Verilog + GTKWave**
- ✅ Synthesized and technology-mapped designs with **Yosys + SKY130**
- ✅ Showed how **constant multiplication (×2, ×9)** collapses into pure wiring / shift-add logic instead of full multiplier hardware
---
 
## 📌 Conclusion
 
<div align="center">
> 🎓 Module 2 built hands-on fluency with **timing libraries**, **synthesis strategies**, **flip-flop coding styles**, **RTL simulation**, **waveform analysis**, and **technology mapping** — connecting the dots between RTL source code and its optimized gate-level silicon implementation.
 
</div>
