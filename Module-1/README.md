# 🔧 Module 1 — Getting Started with Verilog RTL Simulation

<p align="center">
  <img src="https://img.shields.io/badge/Language-Verilog-9cf?style=for-the-badge" alt="Verilog">
  <img src="https://img.shields.io/badge/Tool-Icarus%20Verilog-2f6fed?style=for-the-badge" alt="Icarus Verilog">
  <img src="https://img.shields.io/badge/Tool-GTKWave-e67e22?style=for-the-badge" alt="GTKWave">
  <img src="https://img.shields.io/badge/Tool-Yosys-27ae60?style=for-the-badge" alt="Yosys">
</p>

<p align="center"><em>Part of the <a href="https://github.com/ArpithaGarrepalli/RTL_Workshop">RTL Workshop</a> series</em></p>

---

## 🎯 Overview

This document covers **Module 1** of the RTL Design Workshop, focused on the fundamentals of Verilog RTL design — simulating a **counter design** with Icarus Verilog (`iverilog`), analyzing waveforms in **GTKWave**, and an introduction to logic synthesis with **Yosys**.

| | |
|---|---|
| 🛠️ **Tools used** | Icarus Verilog · GTKWave · Yosys |
| 🧩 **Example design** | 2-bit counter (`good_counter`) |
| 📋 **Prerequisites** | Basic familiarity with digital logic and Linux terminal |

---

## 📑 Table of Contents

| # | Section |
|---|---|
| 1 | [Introduction to the Open-Source Simulator Iverilog](#1️⃣-introduction-to-the-open-source-simulator-iverilog) |
| 1.1 | [Core Concepts: Simulator, Design, Testbench](#-core-concepts-simulator-design-and-testbench) |
| 1.2 | [How Iverilog Fits In](#-how-iverilog-fits-in) |
| 2 | [Labs: Iverilog and GTKWave](#2️⃣-labs-iverilog-and-gtkwave) |
| 3 | [Verilog Code Analysis](#3️⃣-verilog-code-analysis) |
| 4 | [Introduction to Yosys and Logic Synthesis](#4️⃣-introduction-to-yosys-and-logic-synthesis) |
| 5 | [Takeaways](#-takeaways) |

---

## 1️⃣ Introduction to the Open-Source Simulator Iverilog

### 🧩 Core Concepts: Simulator, Design, and Testbench

| Term | Description |
|---|---|
| 🖥️ **Simulator** | A software tool that executes a Verilog description and predicts the resulting hardware behavior without requiring a physical circuit. Used to verify functional correctness prior to synthesis. |
| 📐 **Design** | The Verilog module describing the digital circuit under test. Here, the design is a 2-bit counter that increments on each clock pulse and returns to zero upon reaching a specified count. |
| 🧪 **Testbench** | A separate Verilog module written to exercise the design — it supplies input signals such as clock and reset, drives the simulation, and generates the waveform data analyzed in GTKWave. |

<p align="center">
<img width="800" alt="Design module" src="https://github.com/user-attachments/assets/9be4c713-745a-41cb-9f08-0800d2bf7e28" />
</p>

**Figure 1:** The counter design module.

<p align="center">
<img width="800" alt="Testbench module" src="https://github.com/user-attachments/assets/50d268fc-dbd6-4bc5-ac36-7e2752e48f2e" />
</p>

**Figure 2:** The testbench module.

### 🔄 Simulation Process

1. 📝 The testbench generates the required input signals.
2. ⚙️ The simulator executes the design using those inputs.
3. 📊 The design's output updates in response to changes in clock or reset.
4. 💾 The simulation produces a **VCD** (Value Change Dump) file.
5. 👁️ GTKWave reads the VCD file, allowing the counter's behavior to be verified visually.

### 🔗 How Iverilog Fits In

Iverilog serves as the bridge between the Verilog source files and the waveform ultimately used for verification. It parses both the design and testbench, checks them against Verilog syntax rules, and compiles them into a single simulation executable.

Running that executable doesn't directly produce a visual output — instead, it records every signal transition over time into a **VCD file**, a timestamped log of value changes. GTKWave then reads this log and renders it as the waveform view used for analysis.

<p align="center">
<img width="800" alt="Iverilog to GTKWave flow" src="https://github.com/user-attachments/assets/0a67e138-df4d-4621-94a6-7c5873149444" />
</p>

**Figure 3:** Design + Testbench → Iverilog → VCD File → GTKWave.

---

## 2️⃣ Labs: Iverilog and GTKWave

### ⚙️ 2.1 Setting Up the Environment

Install the required tools:

```bash
sudo apt install iverilog
sudo apt install gtkwave
sudo apt install yosys
```

### 🧪 2.2 Compiling and Running the Simulation

Compile the design and testbench, then execute the resulting simulation:

```bash
iverilog good_counter.v tb_good_counter.v
./a.out
```

<p align="center">
<img width="800" alt="Compile and run simulation" src="https://github.com/user-attachments/assets/e2eec607-33a7-4f08-99de-357059843572" />
</p>

**Figure 4:** Compiling and running the simulation.

### 📊 2.3 Viewing the Waveform

Open the generated waveform in GTKWave:

```bash
gtkwave tb_good_counter.vcd
```

<p align="center">
<img width="800" alt="GTKWave waveform" src="https://github.com/user-attachments/assets/97386438-d073-4e17-9dc2-81da6fd7c3a9" />
</p>

**Figure 5:** Counter waveform viewed in GTKWave.

> ✅ **Result:** The counter design was simulated successfully. The GTKWave waveform confirmed the expected counting and reset behavior.

---

## 3️⃣ Verilog Code Analysis

<details>
<summary>📄 <b>Design — <code>good_counter.v</code></b></summary>

```verilog
module good_counter (input clk , input reset , output reg [1:0] cnt);
wire comp;

assign comp = (cnt == 2'b10);

always @(posedge clk , posedge reset)
begin
	if(reset)
		cnt <= 2'b00;
	else if(comp)
		cnt <= 2'b00;
	else
		cnt <= cnt+1;
end

endmodule
```

</details>

<details>
<summary>📄 <b>Testbench — <code>tb_good_counter.v</code></b></summary>

```verilog
`timescale 1ns / 1ps
module tb_good_counter;
	// Inputs
	reg clk, reset  ;
	// Output
	wire [1:0] cnt;

	// Instantiate the Unit Under Test (UUT)
	good_counter uut (
		.clk(clk),
		.reset(reset),
		.cnt(cnt)
	);

	initial begin
	$dumpfile("tb_good_counter.vcd");
	$dumpvars(0,tb_good_counter);
	// Initialize Inputs
	clk = 0;
	reset = 1;
	#3000 $finish;
	end

endmodule
```

</details>

**🔌 Ports**

| Signal | Direction | Description |
|:---:|:---:|---|
| `clk` | 🟢 Input | Clock signal |
| `reset` | 🟢 Input | Active-high synchronous reset |
| `cnt` | 🔵 Output | 2-bit counter output |

**⚙️ Explanation**

- When `reset` is high, `cnt` is cleared to `0`.
- On every rising clock edge, `cnt` increments by `1`.
- When `cnt` reaches `2` (`2'b10`), it resets to `0` on the next clock edge rather than continuing to `3` — so `cnt` cycles through `0, 1, 2, 0, 1, 2, ...`.

> ✅ **Result:** The reset-on-comparison wraparound behavior of the counter was identified and verified against the waveform.

---

## 4️⃣ Introduction to Yosys and Logic Synthesis

### ⚡ 4.1 What Synthesis Does

Simulation confirms that a design *behaves* correctly, but it doesn't produce hardware. **Synthesis** is the step that translates the Verilog RTL into a **gate-level netlist** — a description of the design built entirely out of standard cells (AND, OR, flip-flops, muxes, etc.) taken from a technology library.

**Yosys** is the open-source synthesis tool used for this step. It reads the `.lib` file for the target technology along with the Verilog source, and maps the RTL onto the available standard cells.

<img width="1600" height="613" alt="image" src="https://github.com/user-attachments/assets/f9631e00-7436-4ee2-b4ee-cfc263f56cae" />

### 🧪 4.2 Lab: Synthesizing the Design

Launch Yosys:

```bash
yosys
```

Read the liberty file for the target technology library:

```bash
read_liberty -lib my_lib/lib/tt_025C_1v80.lib
```

Read the design:

```bash
read_verilog good_counter.v
```

Run synthesis, pointing to the top module:

```bash
synth -top good_counter
```

Map the synthesized design onto the standard cells:

```bash
abc -liberty my_lib/lib/tt_025C_1v80.lib
```

View the resulting gate-level schematic:

```bash
show
```

<img width="1600" height="832" alt="image" src="https://github.com/user-attachments/assets/606d5b88-38f8-4e43-a13e-d7caf1178af0" />

Write out the gate-level netlist:

```bash
write_verilog -noattr good_counter_netlist.v
```

> ✅ **Result:** The counter RTL was successfully synthesized and mapped onto standard cells. The resulting gate-level netlist was generated using Yosys.

---

## 🏁 Takeaways

- ✅ Established how a Simulator, Design, and Testbench relate to one another.
- ✅ Simulated a counter design using Iverilog.
- ✅ Analyzed the resulting waveform in GTKWave.
- ✅ Identified the reset-on-comparison wraparound behavior of the counter.
- ✅ Learned how Yosys converts RTL into a gate-level netlist through logic synthesis.
- ✅ Synthesized the counter design and generated its gate-level netlist.

---



