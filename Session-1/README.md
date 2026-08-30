<div align="center">

⚡ Session 1 — Getting the Toolchain Running: RISC-V, RTL Simulation, and the Physical Design Flow

### *Three Codespaces, One Local Machine: Standing Up the Full RTL-to-GDS Toolchain*

<img src="https://img.shields.io/badge/Tool-RISC--V%20GCC-9c27b0?style=for-the-badge&logo=riscv&logoColor=white" alt="RISC-V GCC">
<img src="https://img.shields.io/badge/Tool-Spike-2196f3?style=for-the-badge&logo=icons8&logoColor=white" alt="Spike">
<img src="https://img.shields.io/badge/Tool-Icarus%20Verilog-2196f3?style=for-the-badge&logo=icons8&logoColor=white" alt="Icarus Verilog">
<img src="https://img.shields.io/badge/Tool-GTKWave-ff9800?style=for-the-badge&logo=waveshare&logoColor=white" alt="GTKWave">
<img src="https://img.shields.io/badge/Tool-Yosys-4caf50?style=for-the-badge&logo=opensourcehardware&logoColor=white" alt="Yosys">
<img src="https://img.shields.io/badge/Tool-OpenROAD-673ab7?style=for-the-badge&logo=opensourcehardware&logoColor=white" alt="OpenROAD">
<img src="https://img.shields.io/badge/PDK-SKY130-e91e63?style=for-the-badge&logo=chip&logoColor=white" alt="SKY130">

<br>

<img src="https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square">
<img src="https://img.shields.io/badge/Environments-3%20Codespaces%20%2B%20Local-blueviolet?style=flat-square">
<img src="https://img.shields.io/badge/Flow-RTL%20to%20GDSII-yellow?style=flat-square">

<sub>🔗 Part of the <a href="https://github.com/ArpithaGarrepalli/RTL_Workshop"><b>RTL Workshop</b></a> series</sub>

</div>

---

## 📖 Overview

> 🟣 This document walks through the first environment-setup session, carried out almost entirely across three separate **GitHub Codespaces**: standing up the RISC-V toolchain, running an RTL simulation sanity check, and pushing a design through a full SKY130 physical design flow. Alongside that, the vsdiat course dashboard and lab file downloads were handled locally on Ubuntu.

<table>
<tr><td>🛠️ <b>Environments used</b></td><td>GitHub Codespaces (×3), local Ubuntu</td></tr>
<tr><td>🧩 <b>Tools covered</b></td><td><code>riscv64-unknown-elf-gcc</code>, <code>spike</code>, <code>git</code>, <code>iverilog</code>, <code>gtkwave</code>, <code>yosys</code>, OpenROAD/ORFS, KLayout</td></tr>
<tr><td>📋 <b>Prerequisites</b></td><td>A GitHub account, a local Ubuntu machine or VM</td></tr>
</table>

## 🎯 Objectives

> 🔨 Compile and run a C program through the **RISC-V cross-compiler** and **Spike** ISA simulator
> ⚖️ Cross-check RISC-V execution against a **native compilation** of the same source
> 🧪 Confirm the **RTL simulation toolchain** (Icarus Verilog + GTKWave) is working end-to-end
> 🏗️ Run a full **SKY130 physical design flow** (RTL → GDSII) using OpenROAD
> 🔍 Visually inspect the final layout in **KLayout**
> 💻 Set up a **local Ubuntu environment** and course dashboard for offline reference

---

## 📑 Table of Contents

| # | Section |
|:-:|---|
| 1️⃣ | [GitHub Codespaces — RISC-V Toolchain](#1️⃣-github-codespaces--risc-v-toolchain) |
| 2️⃣ | [GitHub Codespaces — RTL Simulation Check](#2️⃣-github-codespaces--rtl-simulation-check) |
| 3️⃣ | [GitHub Codespaces — SKY130 Physical Design Flow](#3️⃣-github-codespaces--sky130-physical-design-flow) |
| 4️⃣ | [Local Ubuntu — vsdiat Dashboard and Downloads](#4️⃣-local-ubuntu--vsdiat-dashboard-and-downloads) |
| 🏁 | [Overall Result](#-overall-result) |

---

## 1️⃣ GitHub Codespaces — RISC-V Toolchain

> 🧠 **Background:** RISC-V is an open, royalty-free instruction set architecture (ISA) — a specification for what instructions a processor understands, not a specific chip. Because the ISA is open, anyone can build a compiler, simulator, or actual silicon that implements it, which is why an entire open-source toolchain exists around it.

Two tools matter here:
- `riscv64-unknown-elf-gcc` is a **cross-compiler** — it runs on one architecture (the Codespace's underlying x86/ARM machine) but produces machine code for a *different* architecture (RISC-V). That output can't be run directly on the machine that compiled it.
- `spike` is a **functional ISA simulator** — it emulates a RISC-V CPU in software, executing the cross-compiled RISC-V binary instruction by instruction and reporting what a real RISC-V chip would have done.

### 🖥️ 1.1 Creating the Codespace

The RISC-V toolchain session runs inside a GitHub Codespace created directly (not from a local `git clone`) — the Codespace environment comes pre-configured with the RISC-V toolchain and the `samples` directory already in place.

### ⚙️ 1.2 Compiling and Running with the RISC-V Toolchain

Navigate to the `samples` folder and compile `sum1ton.c` using the RISC-V cross-compiler:

```bash
cd samples
riscv64-unknown-elf-gcc -o sum1ton.o sum1ton.c
```

Run the compiled RISC-V binary using the `spike` ISA simulator:

```bash
spike pk sum1ton.o
```

**Expected output:**

```
Sum from 1 to 9 is 45
```

<img width="357" height="483" alt="Screenshot 2026-08-30 224601" src="https://github.com/user-attachments/assets/6ec0bfca-5671-45ae-8f6c-464e8585ce07" />


**Figure 1:** Disassembly view of the compiled RISC-V binary.

<img width="1107" height="513" alt="Screenshot 2026-08-30 224625" src="https://github.com/user-attachments/assets/846a3c3b-7c80-484c-bb7c-fbcc799513fb" />


**Figure 2:** `spike pk sum1ton.o` producing `Sum from 1 to 9 is 45`.

> ✨ **Insight:** The disassembly view is worth reading in its own right — it's the actual RISC-V machine instructions the compiler generated from the C source, which normally stays hidden behind the compilation step entirely.

### ⚖️ 1.3 Comparing Against Native Compilation

The same source file was also compiled natively (not cross-compiled for RISC-V) to confirm the program's logic is correct independent of the target architecture:

```bash
cc -o sum1ton.o sum1ton.c
./sum1ton.o
```

**Output:**

```
Sum from 1 to 9 is 45
```

<img width="1107" height="451" alt="Screenshot 2026-08-30 224541" src="https://github.com/user-attachments/assets/6eee00d9-db4a-43c3-84aa-665d51092e1a" />


**Figure 3:** Native (non-RISC-V) compilation and execution, producing an identical result.

> ✅ **Result:** Both the RISC-V cross-compiled version (run through `spike`) and the natively-compiled version produce identical output, confirming the C program itself is correct and that the RISC-V toolchain is functioning as expected end-to-end. This distinction matters — a mismatch here would point to a toolchain or simulator problem, not a bug in the C code, since the *same* source produced *different* results depending only on which compiler and execution environment processed it.

---

## 2️⃣ GitHub Codespaces — RTL Simulation Check

> 🧠 **Background:** RTL simulation checks whether a hardware description, written in a language like Verilog, actually behaves the way it's supposed to — before any of it becomes real silicon. Icarus Verilog (`iverilog`) compiles the design together with a testbench (a piece of code that drives inputs and observes outputs) into a runnable simulation. Running that simulation produces a **VCD (Value Change Dump)** file — a timestamped record of every signal's value over time — which GTKWave then renders as a waveform for visual inspection.

A separate Codespace (`vsd-rtl`), inside the `sky130RTLDesignAndSynthesisWorkshop` directory, was used to confirm the RTL simulation toolchain works end-to-end using the `good_mux` design from the RTL workshop:

```bash
ls -ltr
gtkwave tb_good_mux.vcd
```

<img width="972" height="631" alt="Screenshot 2026-08-30 224640" src="https://github.com/user-attachments/assets/d77ae66b-6614-4c06-a444-5acca3931711" />

**Figure 4:** `good_mux` waveform rendered in GTKWave.

> ✅ **Result:** The waveform confirms Icarus Verilog and GTKWave are correctly set up in this Codespace and producing readable results, ahead of the rest of the RTL workshop content.

---

## 3️⃣ GitHub Codespaces — SKY130 Physical Design Flow

> 🧠 **Background:** RTL simulation confirms *behavior*, but it doesn't produce anything manufacturable. The physical design flow — often called **RTL-to-GDS** — is the sequence of steps that turns a logical description into an actual chip layout.

<table>
<tr><td>🔨 <b>Synthesis</b></td><td>Maps the RTL onto real standard cells from a technology library (SKY130HD here)</td></tr>
<tr><td>📐 <b>Floorplanning</b></td><td>Decides the chip's physical dimensions and where major blocks and power structures go</td></tr>
<tr><td>📍 <b>Placement</b></td><td>Positions every individual standard cell within that floorplan</td></tr>
<tr><td>🕐 <b>Clock-tree synthesis (CTS)</b></td><td>Builds the wiring that distributes the clock signal to every flip-flop with minimal skew</td></tr>
<tr><td>🔌 <b>Routing</b></td><td>Draws the actual metal wires connecting every cell according to the design's logical connections</td></tr>
<tr><td>🧱 <b>Fill</b></td><td>Inserts filler cells into unused space to satisfy manufacturing density rules</td></tr>
</table>

The final output is a **GDSII** file — the industry-standard format describing every physical shape on every layer of the chip, ready to be sent to a fabrication facility.

### 🏗️ 3.1 Running the OpenROAD Flow

A third Codespace (`vsd-scl180-orfs`) runs the full RTL-to-GDS physical design flow using OpenROAD's flow scripts (ORFS) against the SKY130HD standard-cell library, using `gcd` as the example design.

```bash
cd orfs/flow
make
```

The flow runs through synthesis, floorplanning, placement, clock-tree synthesis, routing, and fill in sequence, logging elapsed time and peak memory for each stage.

### 🔍 3.2 Viewing the Final GDS in KLayout

Once the flow completes, the final GDSII layout can be opened directly in KLayout for visual inspection. KLayout is a layout viewer/editor for exactly this kind of file — it renders each mask layer (metal, poly, diffusion, etc.) so the physical result of the flow can be checked visually rather than only trusting the log output.

```bash
klayout ./results/sky130hd/gcd/base/6_final.gds
```

<img width="348" height="330" alt="Screenshot 2026-08-30 224712" src="https://github.com/user-attachments/assets/bb8a5544-a758-460f-aa1a-f6ff6e71d554" />


**Figure 5:** Final `gcd` GDSII layout opened in KLayout.

> ✅ **Result:** This confirms the full flow — RTL in, physical GDSII layout out — completes successfully on the SKY130HD platform.

---

## 4️⃣ Local Ubuntu — vsdiat Dashboard and Downloads

> 🧠 **Background:** Codespaces are convenient for running a fixed toolchain in the browser, but they're ephemeral and depend on an internet connection. A local Ubuntu setup — whether a native install or a VM — provides a persistent environment for course materials and offline work, independent of any single Codespace's lifecycle.

### 🌐 4.1 Browsing the vsdiat Course Dashboard

Course content and lesson navigation were handled through the vsdiat dashboard, accessed from a browser on the local Ubuntu machine — used to work through each module's lessons and locate the corresponding lab files.

### 📥 4.2 Downloading Lab Files to Local Ubuntu

After the local Ubuntu environment was set up, the workshop repository was cloned directly:

```bash
git clone https://github.com/kunalg123/sky130RTLDesignAndSynthesisWorkshop.git
cd sky130RTLDesignAndSynthesisWorkshop
```

Lab files and setup scripts referenced from the dashboard were downloaded locally, alongside a local workshop VM used for reference:

<img width="347" height="361" alt="Screenshot 2026-08-30 224723" src="https://github.com/user-attachments/assets/fee33f5b-f51a-414e-ac1b-2fdc8a53149f" />

**Figure 6:** vsdiat dashboard accessed locally on Ubuntu.

<img width="352" height="377" alt="Screenshot 2026-08-30 224659" src="https://github.com/user-attachments/assets/97360703-5ed7-4cfc-8bfb-7757edc66ba8" />


**Figure 7:** Local workshop VM used as a reference environment.

> ✅ **Result:** The local environment mirrors the workshop's directory structure — including `sky130RTLDesignAndSynthesisWorkshop`, `iverilog`, `gtkwave`, and `yosys` — ready for any work done offline rather than in a Codespace.

---

## 🏁 Overall Result

- ✅ Set up and used the **RISC-V toolchain** (`riscv64-unknown-elf-gcc` + `spike`) inside a GitHub Codespace, using Kunal Ghosh's workshop repository
- ✅ Cross-checked **RISC-V execution** against a native compilation of the same C program to confirm correctness independent of target architecture
- ✅ Verified the **RTL simulation toolchain** end-to-end using the `good_mux` waveform in GTKWave, in a separate Codespace
- ✅ Ran a complete **SKY130 physical design flow** (OpenROAD/ORFS) in a third Codespace, from RTL through to a final routed GDSII layout
- ✅ Visually confirmed the final layout in **KLayout**
- ✅ Set up the **vsdiat dashboard** locally on Ubuntu to navigate course content and download lab files for offline reference
