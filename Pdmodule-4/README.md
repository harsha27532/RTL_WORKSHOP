<div align="center">

# ⚡ Module 4 — Building the Clock Tree: Timing Analysis and Physical Optimization

### *Getting the Clock Everywhere on Time: CTS, Skew, and the Setup/Hold Balancing Act*

<img src="https://img.shields.io/badge/Flow-OpenLane%20%2F%20OpenROAD-4caf50?style=for-the-badge&logo=opensourcehardware&logoColor=white" alt="OpenLane / OpenROAD">
<img src="https://img.shields.io/badge/Synthesis-Yosys-e91e63?style=for-the-badge&logo=opensourcehardware&logoColor=white" alt="Yosys">
<img src="https://img.shields.io/badge/STA-OpenSTA-ff9800?style=for-the-badge&logo=icons8&logoColor=white" alt="OpenSTA">
<img src="https://img.shields.io/badge/PDK-SKY130-2196f3?style=for-the-badge&logo=chip&logoColor=white" alt="SKY130">
<img src="https://img.shields.io/badge/Constraints-SDC-9c27b0?style=for-the-badge&logo=icons8&logoColor=white" alt="SDC">
<img src="https://img.shields.io/badge/Env-Docker-0088cc?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">

<br>

<img src="https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square">
<img src="https://img.shields.io/badge/Focus-CTS%20%26%20STA-blueviolet?style=flat-square">
<img src="https://img.shields.io/badge/Design-picorv32a-yellow?style=flat-square">

<sub>🔗 Part of the SKY130 Physical Design module series</sub>

</div>

---

## 📖 Overview

> 🟣 This document walks through the physical-implementation stage of the `picorv32a` design on the OpenLane/OpenROAD flow with the SkyWater SKY130 standard-cell library.

It covers standard-cell placement, Clock Tree Synthesis (CTS), clock buffering and distribution, setup/hold timing analysis, clock skew, crosstalk, and how the supporting Liberty, LEF, SDC, and Tcl files drive each stage.

<table>
<tr><td>🛠️ <b>Tools used</b></td><td>OpenLane, OpenROAD, Yosys, OpenSTA, SKY130 PDK, Liberty (.lib), LEF, SDC, Tcl, Docker</td></tr>
<tr><td>🧩 <b>Example design(s)</b></td><td><code>picorv32a</code></td></tr>
<tr><td>📋 <b>Prerequisites</b></td><td>OpenLane/OpenROAD environment running in Docker, SKY130 PDK installed, a synthesized <code>picorv32a</code> netlist, base SDC constraints defined</td></tr>
</table>

## 🎯 Objectives

> 📚 Understand SKY130's **timing corners** (fast/slow/typical) and the LEF physical format
> 📍 Run **synthesis and placement** on `picorv32a`, then inspect the result
> 📝 Learn how **SDC constraints** and Tcl configs drive each stage of the flow
> 🕐 Understand **Clock Tree Synthesis (CTS)** objectives and clock-tree structure
> 🔌 See how **clock buffers** and **net shielding** shape clock distribution
> ⏱️ Master **setup and hold timing** — the two complementary checks every path must pass
> 🌊 Understand **clock skew** and **crosstalk-induced delta delay**
> 📊 Read **timing slack reports** to find and fix violations

---

## 📑 Table of Contents

| # | Section |
|:-:|---|
| 1️⃣ | [Technology Libraries and Physical Files](#1️⃣-technology-libraries-and-physical-files) |
| 2️⃣ | [The Physical Design Flow, Bird's-Eye View](#2️⃣-the-physical-design-flow-birds-eye-view) |
| 3️⃣ | [Synthesis and Placement on picorv32a](#3️⃣-synthesis-and-placement-on-picorv32a) |
| 4️⃣ | [Setting the Timing Constraints](#4️⃣-setting-the-timing-constraints) |
| 5️⃣ | [Clock Tree Synthesis](#5️⃣-clock-tree-synthesis) |
| 6️⃣ | [Clock Buffers and Clock Distribution](#6️⃣-clock-buffers-and-clock-distribution) |
| 7️⃣ | [Setup and Hold: The Two Timing Checks](#7️⃣-setup-and-hold-the-two-timing-checks) |
| 8️⃣ | [Clock Skew and Crosstalk](#8️⃣-clock-skew-and-crosstalk) |
| 9️⃣ | [Reading Timing Reports and Slack](#9️⃣-reading-timing-reports-and-slack) |
| 🔟 | [Routing Setup: Ports and Track Info](#🔟-routing-setup-ports-and-track-info) |
| 🏁 | [Session Wrap-Up](#-session-wrap-up) |

---

## 1️⃣ Technology Libraries and Physical Files

Technology files tell the physical-design tools how standard cells, routing layers, and timing behave. The SKY130 standard-cell library ships fast, slow, and typical characterization corners, plus a LEF description of each cell's physical footprint.

### 🌡️ 1.1 Standard-Cell Timing Corners

<table>
<tr><td>⚡ <b>Fast corner</b></td><td>Cells characterized under conditions where they switch relatively quickly; used to study minimum-delay behavior and hold timing.</td></tr>
<tr><td>🐢 <b>Slow corner</b></td><td>Cells characterized under conditions where they switch relatively slowly; relevant to maximum-delay and setup timing.</td></tr>
<tr><td>⚖️ <b>Typical corner</b></td><td>Nominal characterized conditions, used for baseline/typical timing evaluation.</td></tr>
</table>

<img width="921" height="531" alt="Fast corner timing data" src="https://github.com/user-attachments/assets/1381335c-9327-4096-9f7f-f1af97b4d5ad" />

**Figure 1:** Fast-corner characterization data.

<img width="922" height="547" alt="Slow corner timing data" src="https://github.com/user-attachments/assets/3df5afb7-fa32-4c46-9703-0a069b0d1f63" />

**Figure 2:** Slow-corner characterization data.

<img width="758" height="490" alt="Typical corner timing data" src="https://github.com/user-attachments/assets/9eecd30d-d5c0-41ec-a600-d307fcf12d7e" />

**Figure 3:** Typical-corner characterization data.

### 📐 1.2 The LEF File

The LEF format captures the physical characteristics of a standard cell — dimensions, pin locations, and routing-related geometry needed for placement and routing.

<img width="652" height="486" alt="LEF file example" src="https://github.com/user-attachments/assets/63c4de48-afce-4b23-913f-cd85d991d859" />

**Figure 4:** A standard-cell LEF entry.

---

## 2️⃣ The Physical Design Flow, Bird's-Eye View

The physical-design flow turns a synthesized netlist into an implementation by placing cells, building the clock network, routing connections, and checking timing:

```text
RTL Design
    |
    v
Synthesis
    |
    v
Floorplanning
    |
    v
Standard-Cell Placement
    |
    v
Placement Optimization
    |
    v
Clock Tree Synthesis
    |
    v
Clock Distribution
    |
    v
Timing Analysis
    |
    v
Routing and Optimization
    |
    v
Physical Verification
```

<table>
<tr><td>🔨 <b>Synthesis</b></td><td>Maps RTL onto standard cells from the target library</td></tr>
<tr><td>📐 <b>Floorplanning</b></td><td>Sets the core area and design boundaries</td></tr>
<tr><td>📍 <b>Placement</b></td><td>Assigns physical locations to cells</td></tr>
<tr><td>🕐 <b>CTS</b></td><td>Builds the clock distribution network with buffers and clock cells</td></tr>
<tr><td>🔌 <b>Routing</b></td><td>Wires cells together on the metal layers</td></tr>
<tr><td>⏱️ <b>Timing analysis</b></td><td>Checks whether the implementation meets its constraints</td></tr>
</table>

---

## 3️⃣ Synthesis and Placement on `picorv32a`

### 🔨 3.1 Running Synthesis

Synthesis converts the RTL into a gate-level netlist mapped onto the chosen standard-cell library; this netlist is what feeds the rest of the physical flow.

<img width="913" height="537" alt="Synthesis run output" src="https://github.com/user-attachments/assets/96c0ab6d-b4a1-4c4e-b62d-3d3b4156f1cc" />

**Figure 5:** Synthesis run for `picorv32a`.

### 📍 3.2 Standard-Cell Placement

Placement locates standard cells inside the core area, weighing cell density, wirelength, connectivity, and timing — a good placement keeps interconnect delay down and eases later timing optimization.

<img width="922" height="547" alt="Standard-cell placement view" src="https://github.com/user-attachments/assets/8ffea235-abb8-4486-a77a-529346306cb9" />

**Figure 6:** Standard-cell placement result.

### 🔍 3.3 A Closer Look at the Placement

A zoomed-in view of the placement makes it easier to see how cells are physically distributed and spatially related within the core.

<img width="925" height="533" alt="Zoomed placement detail" src="https://github.com/user-attachments/assets/050dac76-f644-4815-8de1-b5562dbf824a" />

**Figure 7:** Zoomed-in placement detail.

---

## 4️⃣ Setting the Timing Constraints

Timing constraints capture the design's operating requirements and feed Static Timing Analysis. SDC (Synopsys Design Constraints) is the format used here to define the clock, I/O delays, and timing uncertainty.

### 📝 4.1 The Base SDC File

`my_base.sdc` holds the design's core timing requirements, typically including:

- Clock period and clock definition
- Input and output delays
- Clock uncertainty
- Input transition times
- Output loads

<img width="903" height="525" alt="Base SDC file contents" src="https://github.com/user-attachments/assets/0fbdb50f-4aa7-405e-88ee-b4b46faa424b" />

**Figure 8:** `my_base.sdc` contents.

### ⚙️ 4.2 Pre-CTS and New Tcl Configuration

The pre-CTS configuration holds the settings used for implementation just before Clock Tree Synthesis runs. A separate Tcl configuration file carries additional design/flow settings for physical implementation — these must stay consistent with the chosen technology, design, and timing requirements.

<img width="913" height="741" alt="Pre-CTS and Tcl configuration" src="https://github.com/user-attachments/assets/9ba229d3-8f3b-411e-8ff5-2dee4087f13c" />

**Figure 9:** Pre-CTS and Tcl configuration settings.

---

## 5️⃣ Clock Tree Synthesis

### 🕐 5.1 CTS Objectives and Clock-Tree Structure

**CTS** builds the distribution network that carries the clock from its source to every sequential element. As the number of clock sinks grows, distribution gets harder because of capacitive loading, long interconnects, insertion delay, arrival-time mismatches, clock skew, and transition requirements — CTS inserts buffers and organizes the network to manage all of this.

Its main goals are to:

1. Reach every required clock sink
2. Keep skew between sequential elements under control
3. Keep clock transition times acceptable
4. Manage insertion delay and network loading
5. Support setup and hold requirements
6. Improve overall clock distribution quality

> A clock tree is generally made of a clock source, intermediate buffers, branch points, and sinks; its structure shapes latency, skew, power, and overall timing behavior.

<img width="922" height="483" alt="Clock tree structure, part 1" src="https://github.com/user-attachments/assets/0c3eb074-b387-4aa5-b8bf-c1a19c80d8f2" />

**Figure 10:** Clock tree structure and objectives.

<img width="920" height="485" alt="Clock tree structure, part 2" src="https://github.com/user-attachments/assets/3f6264c7-9c1e-49b5-8c32-ec861924dfc7" />

**Figure 11:** Clock tree branching and sinks.

### ⚙️ 5.2 CTS Configuration (`cts.tcl`)

`cts.tcl` holds the settings that govern the CTS run and how the clock distribution network gets built.

<img width="870" height="427" alt="cts.tcl configuration" src="https://github.com/user-attachments/assets/d2173ec8-19fd-448f-8266-897a0eb066e2" />

**Figure 12:** `cts.tcl` configuration.

---

## 6️⃣ Clock Buffers and Clock Distribution

### 🔌 6.1 Clock Buffer Insertion

Clock buffers drive the capacitive load of clock sinks and help distribute the clock across the design while controlling loading and transition times. Their count, sizing, and placement directly affect insertion delay, skew, and power.

> ✨ **Insight:** Inserting buffers splits one large clock load into smaller loads each buffer can drive, which keeps the clock signal intact and lets it reach physically separated flip-flops.

<img width="1168" height="743" alt="Clock buffer insertion" src="https://github.com/user-attachments/assets/cb28094d-94bb-435e-8723-e87243052660" />

**Figure 13:** Clock buffers inserted across the design.

### 🛡️ 6.2 Clock Net Shielding

Shielding routes a fixed-potential wire alongside a clock net to cut down unwanted coupling from neighboring signal wires — it improves signal integrity at the cost of extra routing resources.

<img width="922" height="510" alt="Clock net shielding" src="https://github.com/user-attachments/assets/5f8fc621-c7c6-4cbd-b1b6-bca1405d64af" />

**Figure 14:** Clock net shielding.

---

## 7️⃣ Setup and Hold: The Two Timing Checks

Setup and hold define the window during which data at a flip-flop's input must stay stable around the active clock edge.

### 🔴 7.1 Setup Time

Setup time is the minimum interval data must be stable **before** the active clock edge. A setup violation happens when data shows up too late. For a simplified register-to-register path:

$$T_{cq} + T_{comb} + T_{setup} \leq T_{period}$$

where $T_{cq}$ is the launching flip-flop's clock-to-Q delay, $T_{comb}$ is the combinational/interconnect delay, $T_{setup}$ is the capturing flip-flop's setup time, and $T_{period}$ is the clock period. The real requirement also folds in clock arrival times and timing uncertainty.

### 🟢 7.2 Hold Time

Hold time is the minimum interval data must stay stable **after** the active clock edge. A hold violation happens when data changes too soon. For a simplified path:

$$T_{cq,min} + T_{comb,min} \geq T_{hold}$$

The actual requirement depends on the launch/capture clock arrival times and the design's timing constraints — hold is especially sensitive to minimum data-path delay.

### 🧪 7.3 Setup Analysis With an Ideal Clock

An ideal clock ignores clock-distribution delay and skew, which makes it useful for looking at data-path timing on its own before the implemented clock tree is factored in.

<img width="887" height="522" alt="Ideal-clock setup analysis, part 1" src="https://github.com/user-attachments/assets/722153d2-4adb-4ef5-b7d0-6fe81ea5ccc0" />

**Figure 15:** Setup analysis with an ideal clock.

<img width="886" height="335" alt="Ideal-clock setup analysis, part 2" src="https://github.com/user-attachments/assets/389f6575-acf4-4689-a05d-da6164262bb1" />

**Figure 16:** Setup timing report detail.

### 🕵️ 7.4 Hold Time Analysis

Hold analysis checks the minimum data-path delay against the hold requirement after the active edge; negative hold slack means the minimum-delay requirement isn't met.

> ✨ **Insight:** Setup and hold checks together evaluate the timing relationship between launching and capturing elements — a path can pass setup and still fail hold, so both checks are necessary.

<img width="807" height="440" alt="Hold time analysis, part 1" src="https://github.com/user-attachments/assets/13e2fb2a-972f-48c7-902b-00541b812684" />

**Figure 17:** Hold time analysis.

<img width="908" height="441" alt="Hold time analysis, part 2" src="https://github.com/user-attachments/assets/88e71119-11e1-44b9-aa31-a3a26ea9cd69" />

**Figure 18:** Hold timing report detail.

---

## 8️⃣ Clock Skew and Crosstalk

### 🌊 8.1 Clock Skew

Clock skew is the difference in clock arrival time between two sequential elements, caused by the clock passing through different buffer/interconnect combinations on its way to each one.

<div align="center">

| Skew type | Meaning |
|:-:|---|
| Positive skew | Capture clock arrives later than the launch clock |
| Negative skew | Capture clock arrives earlier than the launch clock |
| Zero skew | Clock reaches both registers at the same time |

</div>

> Skew affects setup and hold differently depending on its direction and size.

### ⚡ 8.2 Crosstalk and Delta Delay

Crosstalk is unwanted electrical coupling between neighboring interconnects — switching on one net can shift the voltage or delay of a nearby net through capacitive or inductive coupling, affecting transition times, propagation delay, timing margin, and signal integrity.

> ✨ **Insight — crosstalk-induced delta delay:** the change in propagation delay caused by a neighboring net's switching; depending on the relative switching direction and timing, coupling can speed up or slow down a signal.

<img width="917" height="486" alt="Crosstalk delta delay diagram" src="https://github.com/user-attachments/assets/cb251e9f-cd1c-4962-9aee-8fc7915c0c49" />

**Figure 19:** Crosstalk-induced delta delay.

---

## 9️⃣ Reading Timing Reports and Slack

Static Timing Analysis checks whether the design's timing requirements hold, by comparing signal arrival times against required arrival times — without needing input-vector simulation.

### 📊 9.1 Timing Slack

For setup analysis:

$$\text{Setup Slack} = \text{Required Arrival Time} - \text{Data Arrival Time}$$

<div align="center">

| Slack | Meaning |
|:-:|---|
| Positive slack | Timing requirement satisfied |
| Zero slack | Requirement met right at the boundary |
| Negative slack | Timing violation |

</div>

> Setup and hold slack each use their own maximum-delay / minimum-delay checks.

### 🔺 9.2 Maximum-Delay (Setup) Analysis

Maximum-delay analysis checks whether data beats the setup deadline by evaluating the longest relevant paths; negative slack here flags a setup violation.

<img width="792" height="417" alt="Maximum-delay setup analysis report" src="https://github.com/user-attachments/assets/2f68b9cd-8c2e-4506-8b4b-e6ade88dbd98" />

**Figure 20:** Maximum-delay (setup) analysis report.

### 🔻 9.3 Minimum-Delay (Hold) Analysis

Minimum-delay analysis checks whether data arrives late enough to satisfy hold, by evaluating the shortest relevant paths; negative slack here flags a hold violation.

<img width="575" height="375" alt="Minimum-delay hold analysis report" src="https://github.com/user-attachments/assets/2d3049f8-4bd6-4c0b-9a41-868ae3f6dc69" />

**Figure 21:** Minimum-delay (hold) analysis report.

### 📋 9.4 Delay Tables

Timing reports and delay tables list cell delay, interconnect delay, arrival/required times, and slack — helpful for spotting critical paths and understanding how much cells vs. interconnect contribute to overall timing.

<img width="910" height="547" alt="Timing delay table" src="https://github.com/user-attachments/assets/6ec18e70-1682-4e93-a1eb-4fedb35a30e9" />

**Figure 22:** Timing delay table.

---

## 🔟 Routing Setup: Ports and Track Info

### 🔁 10.1 Converting Labels to Ports

Converting labels to ports is a preparation step tied to the design's connectivity and interface representation ahead of physical implementation.

<img width="897" height="526" alt="Label-to-port conversion" src="https://github.com/user-attachments/assets/4ef14ab4-915b-4d48-8de4-5afe3e7a8293" />

**Figure 23:** Converting labels to ports.

### 🗺️ 10.2 Grid-to-Track Conversion and `tracks.info`

Routing-track information marks where wires can be placed on each routing layer; grid information is converted into track information to set this up.

<img width="871" height="520" alt="Grid-to-track conversion" src="https://github.com/user-attachments/assets/088b9296-158b-45d9-906b-90b1f08778ab" />

**Figure 24:** Grid-to-track conversion.

> `tracks.info` holds the routing-track data used through the rest of the physical implementation flow.

<img width="143" height="193" alt="tracks.info file contents" src="https://github.com/user-attachments/assets/dfd8bcda-48a0-45be-8005-3344a0925979" />

**Figure 25:** `tracks.info` contents.

---

## 🏁 Session Wrap-Up

- 📍 Placement directly affects timing — cell locations shape interconnect length and propagation delay
- 🔌 Clock buffers are what make clock distribution practical, spreading a single large clock load across manageable branches
- 🕐 CTS-introduced insertion delay and skew feed straight into setup and hold timing behavior
- ⚖️ Setup and hold checks are complementary — a path can clear one and still fail the other, so both maximum- and minimum-delay analysis are needed
- ⚡ Crosstalk-induced delta delay can shift propagation delay and skew, and shielding is one way to control it
- 📚 Liberty, LEF, and SDC files are the backbone that timing analysis and physical implementation both depend on
- 📊 Slack values and path reports are the practical tools for finding and fixing timing violations during optimization
