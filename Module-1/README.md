# Day 1 — Getting Started with Verilog RTL Simulation

## Overview

This document covers Day 1 of the RTL Design Workshop, focused on the fundamentals of Verilog RTL design: simulating a counter design with Icarus Verilog (`iverilog`), analyzing waveforms in GTKWave, and an introduction to logic synthesis with Yosys.

## Table of Contents

1. Introduction to the Open-Source Simulator Iverilog

* Core Concepts: Simulator, Design, and Testbench
* How Iverilog Fits In

2. Labs: Iverilog and GTKWave

* Setting Up the Environment
* Compiling and Running the Simulation
* Viewing the Waveform
* Verilog Code Analysis

3. Takeaways

## 1. Introduction to the Open-Source Simulator Iverilog

### Core Concepts: Simulator, Design, and Testbench

**Simulator**

A simulator is a software tool that executes a Verilog description and predicts the resulting hardware behavior without requiring a physical circuit. It is used to verify functional correctness prior to synthesis.

**Design**

The design refers to the Verilog module describing the digital circuit under test. In this example, the design is a 2-bit counter that increments on each clock pulse and returns to zero upon reaching a specified count.
<img width="1600" height="899" alt="image" src="https://github.com/user-attachments/assets/9be4c713-745a-41cb-9f08-0800d2bf7e28" />


**Testbench**

The testbench is a separate Verilog module written to exercise the design. It supplies input signals such as clock and reset, drives the simulation, and generates the waveform data subsequently analyzed in GTKWave.
<img width="1600" height="899" alt="image" src="https://github.com/user-attachments/assets/50d268fc-dbd6-4bc5-ac36-7e2752e48f2e" />


**Simulation Process**

1. The testbench generates the required input signals.
2. The simulator executes the design using those inputs.
3. The design's output updates in response to changes in clock or reset.
4. The simulation produces a VCD (Value Change Dump) file.
5. GTKWave reads the VCD file, allowing the counter's behavior to be verified visually.

### How Iverilog Fits In

Iverilog serves as the bridge between the Verilog source files and the waveform ultimately used for verification. It parses both the design and testbench, checks them against Verilog syntax rules, and compiles them into a single simulation executable. Running that executable does not directly produce a visual output; instead, it records every signal transition over time into a VCD file — a timestamped log of value changes. GTKWave then reads this log and renders it as the waveform view used for analysis.
<img width="1600" height="899" alt="image" src="https://github.com/user-attachments/assets/0a67e138-df4d-4621-94a6-7c5873149444" />


## 2. Labs: Iverilog and GTKWave

### Setting Up the Environment

Install the required tools:

```
sudo apt install iverilog
sudo apt install gtkwave
```

### Compiling and Running the Simulation

Compile the design and testbench, then execute the resulting simulation:

```
iverilog good_counter.v tb_good_counter.v
./a.out
```
<img width="1917" height="991" alt="codesharsha" src="https://github.com/user-attachments/assets/e2eec607-33a7-4f08-99de-357059843572" />


### Viewing the Waveform

Open the generated waveform in GTKWave:

```
gtkwave tb_good_counter.vcd
```
<img width="1907" height="1001" alt="gtkharssha" src="https://github.com/user-attachments/assets/97386438-d073-4e17-9dc2-81da6fd7c3a9" />


### Verilog Code Analysis

**Design — `good_counter.v`**

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

**Testbench — `tb_good_counter.v`**

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

**Explanation**

* Inputs: `clk`, `reset`
* Output: `cnt` (2-bit)
* When `reset` is high, `cnt` is cleared to `0`.
* On every rising clock edge, `cnt` increments by `1`.
* When `cnt` reaches `2` (`2'b10`), it resets to `0` on the next clock edge rather than continuing to `3` — so `cnt` cycles through `0, 1, 2, 0, 1, 2, ...`.

## 3. Takeaways

* Established how a Simulator, Design, and Testbench relate to one another.
* Simulated a counter design using Iverilog.
* Analyzed the resulting waveform in GTKWave.
* Identified the reset-on-comparison wraparound behavior of the counter.
