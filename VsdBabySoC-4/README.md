<div align="center">

# ⚡ Session 3 — VSDBabySoC Synthesis Recap, Multi-Corner STA, and Physical Design

### *From RTL and Gate-Level Netlists to Timing Analysis and a Routed Layout*

<img src="https://img.shields.io/badge/Language-Verilog-9c27b0?style=for-the-badge&logo=v&logoColor=white" alt="Verilog">
<img src="https://img.shields.io/badge/Tool-Yosys-4caf50?style=for-the-badge&logo=opensourcehardware&logoColor=white" alt="Yosys">
<img src="https://img.shields.io/badge/Tool-OpenSTA-2196f3?style=for-the-badge&logo=icons8&logoColor=white" alt="OpenSTA">
<img src="https://img.shields.io/badge/Tool-OpenROAD-ff9800?style=for-the-badge&logo=waveshare&logoColor=white" alt="OpenROAD">
<img src="https://img.shields.io/badge/PDK-SKY130-e91e63?style=for-the-badge&logo=chip&logoColor=white" alt="SKY130">

<br>

<img src="https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square" alt="Status: Completed">
<img src="https://img.shields.io/badge/Focus-Static%20Timing%20Analysis-yellow?style=flat-square" alt="Focus: Static Timing Analysis">
<img src="https://img.shields.io/badge/Featured-VSDBabySoC-blueviolet?style=flat-square" alt="Featured: VSDBabySoC">

<sub>🔗 Part of the RTL Design and Synthesis Workshop series</sub>

</div>

---

## 📖 Overview

This document covers two connected stages of the VSDBabySoC work. The first half recaps what synthesis does to an RTL design and why a gate-level netlist can look very different from the RTL it came from. The second half moves on to static timing analysis with OpenSTA across multiple PVT corners, in both a VM (pre-route) and a Codespace (post-route), followed by a walkthrough of the OpenROAD physical design flow for the same design.

| | |
|---|---|
| 🛠️ **Tools used** | Yosys, OpenSTA, OpenROAD |
| 🧩 **Example design** | VSDBabySoC on the SKY130 HD platform |
| 📋 **Prerequisites** | Familiarity with RTL synthesis, gate-level simulation, and the Linux terminal |

## 🎯 Objectives

> 🔀 Understand why internal gate-level waveforms can differ from RTL without automatically indicating a bug
> 
> 🧩 Understand how synthesis optimization and the SKY130 standard-cell library affect the mapped netlist
> 
> ⏱️ Use OpenSTA to interpret timing paths, slack, WNS, and TNS
> 
> 🌡️ Compare pre-route and post-route timing across 16 PVT corners
> 
> 🏗️ Walk through the OpenROAD flow from synthesis to floorplanning, placement, and routing

---

## 📑 Table of Contents

- 1. Why Internal Waveforms Can Differ
- 2. RTL vs Gate-Level
- 3. Role of the SKY130 Standard-Cell Library
- 4. Important Observations
  - 4.1 RTL Coding Matters
  - 4.2 Synthesis Changes Structure
  - 4.3 Optimization Changes the Implementation
  - 4.4 Technology Libraries Matter
  - 4.5 GLS Is Important
  - 4.6 Internal Signals Can Change
- 5. Complete Synthesis Command Flow
- 6. Static Timing Analysis Using OpenSTA
  - 6.1 Introduction
  - 6.2 Important Timing Parameters
  - 6.3 OpenSTA Commands
- 7. Static Timing Analysis on VSDBabySoC — VM
  - 7.1 Overview
  - 7.2 VM Run TCL Script
  - 7.3 VM Timing Reports — Representative Corners
  - 7.4 VM WNS and TNS Graphs
  - 7.5 Observations
- 8. SKY130 Timing Libraries — PVT Corners
  - 8.1 Introduction
  - 8.2 SKY130 HD Timing Libraries
  - 8.3 Process Corner Categories
- 9. PVT Corner-Based STA — Codespace
  - 9.1 Overview
  - 9.2 Analysis Setup
  - 9.3 Codespace TCL Script
  - 9.4 Timing Report Commands
  - 9.5 PVT Corner Coverage
  - 9.6 Timing Reports — Four Representative Corners
  - 9.7 Summary Report
  - 9.8 WNS and TNS Graphs
  - 9.9 Observations
- 10. Physical Design Flow Using OpenROAD
  - 10.1 Introduction
  - 10.2 Synthesis
  - 10.3 Floorplanning
  - 10.4 Placement
  - 10.5 Routing
  - 10.6 Observations
- 11. Takeaways
- Author

---

## 1️⃣ Why Internal Waveforms Can Differ

Synthesis may perform:

- Logic optimization
- Constant propagation
- Logic merging
- Redundant logic removal
- Technology mapping
- Hierarchy flattening
- Internal signal renaming

> ✅ **Key result:** The internal gate-level structure does not have to be identical to the RTL structure.
>
> 💡 **Insight:** A different internal waveform does not automatically indicate a functional error — compare the behaviour of meaningful observable signals and outputs.

---

## 2️⃣ RTL vs. Gate-Level, and the Role of the SKY130 Library

| RTL | Gate-Level |
|---|---|
| Higher abstraction | Lower abstraction |
| Behaviour-oriented | Structure-oriented |
| Easier to read | More detailed |
| Technology independent | Technology mapped |
| Describes intended functionality | Describes cell connectivity |
| Used for functional verification | Used for post-synthesis verification |

---

## 3️⃣ The Role of the SKY130 Standard-Cell Library

The standard-cell library determines which technology-specific cells can be used during mapping. The relationship is:

```text
RTL
 ↓
Generic Logic
 ↓
Technology Mapping
 ↓
SKY130 Standard Cells
```

Examples of standard-cell types include:

```text
INV
NAND
NOR
AND
OR
XOR
MUX
D Flip-Flop
```

> ✅ **Result:** The selected technology library influences the structure of the final gate-level netlist.

---

## 4️⃣ Important Observations from Synthesis and GLS

### 4.1 RTL Coding Matters

The MUX experiments demonstrated that RTL coding style influences how synthesis interprets the design.

### 4.2 Synthesis Changes Structure

The gate-level netlist can be structurally very different from the RTL.

### 4.3 Optimization Changes the Implementation

Redundant or unnecessary logic may be simplified or removed while preserving functionality.

### 4.4 Technology Libraries Matter

The available technology library determines the cells used during technology mapping.

### 4.5 GLS Is Important

RTL simulation verifies the original RTL, while GLS verifies the synthesized gate-level implementation.

### 4.6 Internal Signals Can Change

Synthesis may rename, optimize, or remove internal signals, so functional comparison should focus on meaningful signals and outputs.

---

## 5️⃣ The Complete Synthesis Command Flow

```bash
yosys

read_verilog src/module/vsdbabysoc.v
read_verilog -I src/include src/module/rvmyth.v
read_verilog -I src/include src/module/clk_gate.v

read_liberty -lib lib/avsdpll.lib
read_liberty -lib lib/avsddac.lib
read_liberty -lib lib/sky130_fd_sc_hd__tt_025C_1v80.lib

synth -top vsdbabysoc

dfflibmap -liberty lib/sky130_fd_sc_hd__tt_025C_1v80.lib

opt

abc -liberty lib/sky130_fd_sc_hd__tt_025C_1v80.lib

check

show vsdbabysoc

flatten
setundef -zero
clean -purge
rename -enumerate

write_verilog -noattr netlist/babysoc_netlist_new.v
```

---

## 6️⃣ Static Timing Analysis with OpenSTA

### ⏱️ 6.1 What STA Checks

Static Timing Analysis (STA) evaluates the timing behaviour of a digital circuit without requiring exhaustive functional simulation. It analyses signal propagation delays and checks whether timing paths satisfy the specified timing constraints.

OpenSTA is an open-source static timing analysis tool. In this work, it was used to examine timing paths in VSDBabySoC using SKY130 HD standard-cell timing libraries. The analysis involves loading the design netlist, timing constraints, and libraries, generating timing reports, and evaluating timing behaviour across different Process, Voltage, and Temperature (PVT) conditions.

### 📊 6.2 Important Timing Parameters

| Parameter | Description |
|---|---|
| Startpoint | Beginning of a timing path |
| Endpoint | End of a timing path |
| Arrival time | Time at which a signal reaches the endpoint |
| Required time | Time by which the signal must arrive |
| Slack | Difference between required time and arrival time, interpreted according to the timing check |
| WNS | Worst Negative Slack; the worst reported timing slack |
| TNS | Total Negative Slack; accumulated negative slack across violating paths |

> ✅ **Interpretation:** Positive slack generally indicates that a path meets its timing requirement. Negative slack indicates a timing violation.

### ⌨️ 6.3 OpenSTA Commands

Check whether OpenSTA is available in the VM:

```bash
which sta
sta -version
```

Inspect minimum- and maximum-delay timing paths:

```tcl
report_checks -path_delay min_max -fields {nets cap slew input_pins fanout}
```

The report provides timing-path details, including net information, capacitance, slew, input pins, and fanout.

---

## 7️⃣ Pre-Route STA on VSDBabySoC (VM)

### 🟦 7.1 Pre-Route Analysis Overview

Static Timing Analysis was performed on the synthesized VSDBabySoC design in the virtual machine using OpenSTA and SKY130 HD timing libraries. This analysis focuses on the **pre-route** design. The results help identify timing violations and understand how timing behaviour changes across PVT corners.

The VM screenshots are stored in the `images/` directory. The original filenames contain `(report checks)`.

### ⌨️ 7.2 The VM `run.tcl` Script

The two parts of the VM `run.tcl` file:

**Part 1**


<img width="1767" height="916" alt="Screenshot 2026-10-15 223133" src="https://github.com/user-attachments/assets/98dc9bdd-3c3e-4af3-b68b-a806504448cc" />



**Part 2**


<img width="1272" height="927" alt="Screenshot 2026-10-15 223154" src="https://github.com/user-attachments/assets/3bf4a141-44d0-41a6-a2ab-49189ea262eb" />


### 🌡️ 7.3 VM Timing Reports — Representative Corners

Each selected corner has two screenshot parts.

**Corner 1: SS, -40°C, 1.28 V**

This corner produced the following pre-route timing results:

| Metric | Value |
|---|---:|
| WNS | -62.56 ns |
| TNS | -13957.59 ns |


<img width="403" height="418" alt="Screenshot 2026-10-15 223208" src="https://github.com/user-attachments/assets/36265264-03a4-482c-b9ce-a0701edb027a" />


**Corner 2: SS, -40°C, 1.35 V**


<img width="403" height="418" alt="Screenshot 2026-10-15 223208" src="https://github.com/user-attachments/assets/2032e076-8ab5-41cb-8cde-c6b31a144275" />



<img width="856" height="918" alt="Screenshot 2026-10-15 223232" src="https://github.com/user-attachments/assets/f40203b0-8838-4541-a255-1aadab0560ce" />
**Corner 3: SS, -40°C, 1.44 V

<img width="672" height="925" alt="Screenshot 2026-10-15 223242" src="https://github.com/user-attachments/assets/7d3b7f71-7e58-4f6c-ac9f-cc0b179095de" />

<img width="655" height="707" alt="Screenshot 2026-10-15 223253" src="https://github.com/user-attachments/assets/cc2c45fd-46ee-4a24-a5b4-ed13d82f24ab" />


**Corner 4: SS, 100°C, 1.40 V**
<img width="785" height="866" alt="Screenshot 2026-10-15 223320" src="https://github.com/user-attachments/assets/691fd85b-f61c-4004-b4d0-b0a8d52a818c" />

<img width="916" height="792" alt="Screenshot 2026-10-15 223334" src="https://github.com/user-attachments/assets/223ed63e-db53-4c61-928f-6b9c43e16831" />


### 📈 7.4 VM WNS and TNS Graphs

The WNS graph helps identify the worst reported slack across the evaluated corners. The TNS graph shows the accumulated negative slack of violating paths.

**VM WNS graph**

<img width="1861" height="735" alt="Screenshot 2026-10-15 223357" src="https://github.com/user-attachments/assets/63f9cb08-9440-4d9c-8b62-7c59593ad58f" />


**VM TNS graph**

<img width="1890" height="766" alt="Screenshot 2026-10-15 223409" src="https://github.com/user-attachments/assets/0459d413-7c67-4390-ad95-7eb9498a7c6e" />


### 💡 7.5 Observations

- The VM analysis examines the synthesized design before routing.
- The reported timing results vary across the selected timing libraries.
- The `ss_n40C_1v28` corner shows substantial negative WNS and TNS.
- WNS and TNS provide complementary information about timing violations.
- These results belong to the VM pre-route analysis and must be distinguished from the Codespace post-route results.

---

## 8️⃣ SKY130 Timing Libraries and PVT Corners

### 📚 8.1 Why PVT Corners Exist

Timing libraries provide timing and electrical models for standard cells, allowing tools to estimate cell delays under specified operating conditions. PVT stands for:

- **Process:** manufacturing-process variation.
- **Voltage:** supply-voltage condition.
- **Temperature:** operating-temperature condition.

Different PVT conditions can produce different cell delays, so analysing multiple corners helps evaluate timing behaviour across operating conditions.

### 🧰 8.2 SKY130 HD Timing Libraries

The SKY130 HD timing-library directory was inspected in the VM. The library filenames identify their process corner, temperature, and supply-voltage conditions.

The libraries were used as inputs to the timing analysis. The GitHub repository documents the library inspection and analysis results; the complete timing-library files do not need to be uploaded.

### 🌡️ 8.3 Process Corner Categories

| Corner | Description |
|---|---|
| FF | Fast-Fast |
| SS | Slow-Slow |
| TT | Typical-Typical |

The VM analysis evaluated 16 corners: 6 FF, 8 SS, and 2 TT.

---

## 9️⃣ Post-Route STA Across 16 PVT Corners (Codespace)

### 🟧 9.1 Post-Route Analysis Overview

A separate multi-corner Static Timing Analysis was performed in Codespace using the VSDBabySoC physical-design environment. Unlike the VM analysis, the Codespace report evaluates the **routed** design using OpenROAD and the associated timing constraints, covering minimum- and maximum-delay timing behaviour across 16 PVT corners.

The Codespace screenshots are stored in `images_codespace/`. Their filenames use `rpt(1)` and `rpt(2)` for the two parts of each corner report.

### 🛠️ 9.2 Analysis Setup

The Codespace report documents the following files and directories:

| Item | Path |
|---|---|
| Routed design database | `results/sky130hd/vsdbabysoc/base/5_route.odb` |
| Timing constraints | `results/sky130hd/vsdbabysoc/base/5_route.sdc` |
| Standard-cell timing libraries | `designs/sky130hd/vsdbabysoc/libs/timing/` |
| PLL timing library | `designs/sky130hd/vsdbabysoc/lib/avsdpll.lib` |
| DAC timing library | `designs/sky130hd/vsdbabysoc/lib/avsddac.lib` |
| Report directory | `reports/sta_minmax_16/` |
| Summary CSV | `reports/sta_minmax_16/minmax_slack_summary.csv` |
| TCL script | `/tmp/sta_minmax.tcl` |

These paths describe the Codespace analysis environment.

### ⌨️ 9.3 Codespace TCL Script

**Additional STA script**
<img width="1836" height="562" alt="Screenshot 2026-10-15 223426" src="https://github.com/user-attachments/assets/46305161-4e4e-4249-b0aa-dea3a1fda4b3" />

### 📊 9.4 Timing Report Commands

The following commands were used to inspect timing paths and report slack metrics:

```tcl
report_checks -path_delay min_max -fields {nets cap slew input_pins fanout}

report_wns -min
report_wns -max

report_tns -min
report_tns -max
```

> 💡 **Insight:** Minimum-delay and maximum-delay checks evaluate different timing requirements and must be interpreted separately.

### 🌡️ 9.5 PVT Corner Coverage

| Corner group | Number of corners |
|---|---:|
| FF | 6 |
| SS | 8 |
| TT | 2 |
| **Total** | **16** |

### 🔎 9.6 Timing Reports — Four Representative Corners

The post-route report recorded maximum-delay violations in five SS corners. The following four reports show representative results for the corners with the most negative reported WNS values.

**Corner 1: SS, -40°C, 1.28 V**

| Metric | Value |
|---|---:|
| WNS | -20.83 ns |
| TNS | -5815.72 ns |

<img width="1306" height="750" alt="Screenshot 2026-10-15 223443" src="https://github.com/user-attachments/assets/5b584a83-4c33-47f8-b77d-b520791ecd6b" />


<img width="1647" height="905" alt="Screenshot 2026-10-15 223500" src="https://github.com/user-attachments/assets/7351e009-105f-47d2-aeb3-9acc39a3287f" />


**Corner 2: SS, -40°C, 1.35 V**

| Metric | Value |
|---|---:|
| WNS | -10.66 ns |
| TNS | -2019.57 ns |

<img width="1635" height="860" alt="Screenshot 2026-10-15 223512" src="https://github.com/user-attachments/assets/33e723e4-a617-4562-ab96-28608a78e4de" />


<img width="1705" height="780" alt="Screenshot 2026-10-15 223529" src="https://github.com/user-attachments/assets/6bf88ed2-4223-45a5-beb8-cbe5dbc872ec" />

**Corner 3: SS, -40°C, 1.40 V**

| Metric | Value |
|---|---:|
| WNS | -6.36 ns |
| TNS | -762.02 ns |

<img width="1153" height="588" alt="Screenshot 2026-10-15 223551" src="https://github.com/user-attachments/assets/511228a4-b327-4d52-9180-23c64f2fafc2" />

<img width="1150" height="605" alt="Screenshot 2026-10-15 223604" src="https://github.com/user-attachments/assets/efc41c5f-e297-4ac0-bc71-f89de24116ef" />


**Corner 4: SS, -40°C, 1.44 V**

| Metric | Value |
|---|---:|
| WNS | -3.82 ns |
| TNS | -168.54 ns |

<img width="1140" height="610" alt="Screenshot 2026-10-15 223617" src="https://github.com/user-attachments/assets/ff28257e-f3ae-4e15-a3e9-15be6a5fb223" />


<img width="1153" height="675" alt="Screenshot 2026-10-15 223628" src="https://github.com/user-attachments/assets/52f6d6ea-63cd-4fdb-a03d-3a099a3cc76c" />

### 📋 9.7 Summary Report

The summary report provides an overview of the multi-corner timing analysis.

<img width="1147" height="417" alt="Screenshot 2026-10-15 223637" src="https://github.com/user-attachments/assets/92f9ed6a-adbf-45cd-a64d-d922300e1442" />


### 📈 9.8 WNS and TNS Graphs

**Codespace WNS graph**

<img width="1452" height="667" alt="Screenshot 2026-10-15 225254" src="https://github.com/user-attachments/assets/1502eaa9-6197-4886-93c6-e98bc38aee4c" />


**Codespace TNS graph**

<img width="1556" height="675" alt="Screenshot 2026-10-15 225314" src="https://github.com/user-attachments/assets/6c25d458-a6db-4ad7-a34d-b24f4b445582" />


### 💡 9.9 Observations

- The Codespace analysis evaluates the routed VSDBabySoC design.
- Five SS corners showed maximum-delay timing violations.
- The `ss_n40C_1v28` corner produced the most negative reported WNS.
- WNS indicates the worst reported slack, while TNS represents accumulated negative slack.
- The VM and Codespace results represent different analysis stages and should not be treated as interchangeable.
- The full set of corner reports is retained in the repository as supporting evidence.

---

## 🔟 Walking the OpenROAD Physical Design Flow

### 🏗️ 10.1 Introduction

The OpenROAD physical-design flow was explored using VSDBabySoC and the SKY130 HD platform. The work includes synthesis, floorplanning, placement, and routing. The design configuration used was:

```bash
./designs/sky130hd/vsdbabysoc/config.mk
```

### 🔨 10.2 Synthesis

Synthesis generates a gate-level implementation from the RTL using the selected technology libraries.

```bash
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk synth
```

### 📐 10.3 Floorplanning

Floorplanning establishes the initial physical organisation of the design.

```bash
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk floorplan
```

The `gui_floorplan` results were inspected to view the floorplan layout and its associated timing information.

<img width="1148" height="608" alt="Screenshot 2026-10-15 223847" src="https://github.com/user-attachments/assets/458ca758-7ae2-4bc1-a9ba-0d3f4efb69c0" />

<img width="1155" height="577" alt="Screenshot 2026-10-15 223859" src="https://github.com/user-attachments/assets/f6e03306-64c6-4357-abca-52b547ca98e8" />


### 🧱 10.4 Placement

Placement assigns physical locations to standard cells within the placement region.

```bash
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk place
```

The `gui_placement` results were inspected to view the placement layout and timing information.

<img width="1147" height="537" alt="Screenshot 2026-10-15 223907" src="https://github.com/user-attachments/assets/217ea7cd-6875-4be1-92a5-83b1425235fc" />


<img width="1146" height="438" alt="Screenshot 2026-10-15 223914" src="https://github.com/user-attachments/assets/494225bf-4302-4b35-957d-07778e7dd3d7" />

### 🛣️ 10.5 Routing

Routing connects the placed standard cells through the available metal layers.

```bash
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk route
```

The `gui_routing` results were inspected to view the routed layout and associated timing information.

<img width="1151" height="568" alt="Screenshot 2026-10-15 223924" src="https://github.com/user-attachments/assets/50481b04-8d7b-48e3-b949-a9f7013c8913" />

<img width="1158" height="620" alt="Screenshot 2026-10-15 223930" src="https://github.com/user-attachments/assets/5ef3ddb2-7185-4c7c-ab08-3a4f5895fd7f" />

### 💡 10.6 Observations

- `gui_floorplan` provides a view of the floorplanned design.
- `gui_placement` provides a view of the placed standard cells.
- `gui_routing` provides a view of the routed design.
- The GUI views help connect the physical layout with timing information reported during the flow.
- > 💡 **Insight:** The routed design is the appropriate implementation stage for post-route timing analysis.

---

## 🏁 Overall Result and Key Takeaways

The flow studied across this work:

```text
RTL Coding
     ↓
RTL Simulation
     ↓
Functional Verification
     ↓
Synthesis
     ↓
Logic Optimization
     ↓
Sequential Cell Mapping
     ↓
Technology Mapping
     ↓
Gate-Level Netlist
     ↓
Gate-Level Simulation
     ↓
Functional Comparison
     ↓
Static Timing Analysis
     ↓
Physical Design (Floorplan → Placement → Routing)
```

- ✅ Connected RTL coding style to the hardware synthesis infers, using the MUX experiments, and extended that understanding to a larger hierarchical design with VSDBabySoC.
- ✅ Understood how optimization, technology mapping, and the choice of technology library change a gate-level netlist relative to its RTL.
- ✅ Used static timing analysis with OpenSTA, including TCL scripts and timing commands, to inspect timing paths.
- ✅ Applied the timing metrics — arrival time, required time, slack, WNS, and TNS — to real reports.
- ✅ Evaluated timing across 16 PVT corners (6 FF, 8 SS, 2 TT) using the SKY130 HD timing libraries.
- ✅ Distinguished VM pre-route results from Codespace post-route results, rather than treating them as interchangeable.
- ✅ Explored the OpenROAD flow — synthesis, floorplanning, placement, and routing — through its GUI views.
- ✅ Identified the operating conditions under which maximum-delay requirements were not met.

The VM report showed substantial negative slack in the `ss_n40C_1v28` pre-route analysis. The Codespace post-route report also identified five SS corners with maximum-delay violations, with `ss_n40C_1v28.lib` producing the most negative reported WNS. These results show why timing has to be evaluated across multiple PVT conditions and interpreted according to the implementation stage.

More broadly, RTL design is not only about writing code that produces the expected simulation output. It also means understanding how synthesis interprets the RTL, how optimization changes the implementation, how technology libraries influence the mapped hardware, and how timing constraints, standard-cell libraries, PVT conditions, and physical implementation together determine the timing behaviour of a digital circuit.

---

## 👤 Author

**Arpitha Garrepalli**
Department of Electronics and Communication Engineering (ECE)
Anurag University


