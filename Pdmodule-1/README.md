<div align="center">

# ⚡ Module 1 — From Open-Source EDA to the SKY130 PDK: How OpenLANE Ties It Together

### *Before Touching a Tool: How Software Becomes Silicon*

<img src="https://img.shields.io/badge/Tool-OpenLANE-9c27b0?style=for-the-badge&logo=opensourcehardware&logoColor=white" alt="OpenLANE">
<img src="https://img.shields.io/badge/Tool-OpenROAD-673ab7?style=for-the-badge&logo=opensourcehardware&logoColor=white" alt="OpenROAD">
<img src="https://img.shields.io/badge/Tool-Magic-2196f3?style=for-the-badge&logo=icons8&logoColor=white" alt="Magic">
<img src="https://img.shields.io/badge/PDK-SKY130-e91e63?style=for-the-badge&logo=chip&logoColor=white" alt="SKY130">
<img src="https://img.shields.io/badge/Flow-RTL--to--GDS-4caf50?style=for-the-badge&logo=opensourcehardware&logoColor=white" alt="RTL to GDS">

<br>

<img src="https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square">
<img src="https://img.shields.io/badge/Focus-EDA%20Fundamentals-blueviolet?style=flat-square">
<img src="https://img.shields.io/badge/Lab-picorv32a%20via%20OpenLANE-yellow?style=flat-square">

<sub>🔗 Part of the Chip Design Program — Physical Design series</sub>

</div>

---

## 📖 Overview

> 🟣 This module covers the background needed before touching any physical design tool: how software ultimately becomes hardware, what an open-source ASIC design flow actually consists of, what a PDK is and why it exists, and a first look at **OpenLANE** as the automated flow that ties RTL, EDA tools, and the SKY130 PDK together into a finished GDSII layout.

<table>
<tr><td>🛠️ <b>Tools covered</b></td><td>OpenLANE, OpenROAD, Yosys, OpenSTA, Magic, Netgen, Fault</td></tr>
<tr><td>🧩 <b>PDK</b></td><td>SKY130 (Google + SkyWater, open-source 130nm)</td></tr>
<tr><td>📋 <b>Prerequisites</b></td><td>Basic familiarity with digital logic and the Linux terminal</td></tr>
</table>

## 🎯 Objectives

> 🔗 Trace the full chain from **application software** down to physical hardware
> 🧩 Understand the three ingredients of an **open-source ASIC flow** — RTL, EDA tools, PDK
> 📚 Learn what a **PDK** is and the history behind separating design from fabrication
> 🗺️ Survey the **EDA tools landscape** and how it collapses into a simplified RTL-to-GDSII flow
> 🔨 Walk through **OpenLANE's** internal flow — DFT, PnR, antenna fixes, design space exploration
> 🧪 Explore the **SKY130 PDK directory structure** and run a real design through OpenLANE

---

## 📑 Table of Contents

| # | Section |
|:-:|---|
| 1️⃣ | [How Software Turns Into Hardware](#1️⃣-how-software-turns-into-hardware) |
| 2️⃣ | [The Three Ingredients of Open-Source ASIC Design](#2️⃣-the-three-ingredients-of-open-source-asic-design) |
| 3️⃣ | [What Exactly Is a PDK?](#3️⃣-what-exactly-is-a-pdk) |
| 4️⃣ | [SKY130 — An Open-Source PDK](#4️⃣-sky130--an-open-source-pdk) |
| 5️⃣ | [Surveying the EDA Tools Landscape](#5️⃣-surveying-the-eda-tools-landscape) |
| 6️⃣ | [The RTL-to-GDSII Flow, Simplified](#6️⃣-the-rtl-to-gdsii-flow-simplified) |
| 7️⃣ | [Meet OpenLANE](#7️⃣-meet-openlane) |
| 8️⃣ | [Lab — Touring the SKY130 PDK Directory](#8️⃣-lab--touring-the-sky130-pdk-directory) |
| 9️⃣ | [Lab — Bringing Up OpenLANE](#9️⃣-lab--bringing-up-openlane) |
| 🔟 | [Lab — Running picorv32a Through OpenLANE](#🔟-lab--running-picorv32a-through-openlane) |
| 🏁 | [Session Wrap-Up](#-session-wrap-up) |

---

## 1️⃣ How Software Turns Into Hardware

Before getting into ASIC-specific tools, it helps to place chip design inside the bigger picture of how any program eventually runs on hardware. Application software and system software both eventually reduce to instructions a compiler and assembler turn into binary — and that binary only means something because a specific piece of hardware was built to understand it.

<img width="1917" height="922" alt="Screenshot 2026-09-06 224516" src="https://github.com/user-attachments/assets/5c75e711-1308-4ba9-8a6a-46420088436e" />

**Figure 1:** The abstraction stack from application software down to hardware.

The same idea applies directly to RISC-V: a C program is cross-compiled and assembled into RISC-V machine code, and that machine code only runs correctly because a specific RTL implementation (like `picorv32`) was built, synthesized, and laid out in silicon to execute exactly that instruction set.

<img width="1912" height="922" alt="Screenshot 2026-09-06 224535" src="https://github.com/user-attachments/assets/1d6b718c-e988-4a31-889b-b51d1c88b654" />

**Figure 2:** C source → RISC-V binary → hardware that executes it.

> ✨ **Insight:** Zooming into a single instruction makes the chain explicit: an instruction like `add x6, x10, x6` is defined by the Instruction Set Architecture (the "architecture" of the computer), assembled into binary, and that same binary can be traced forward into a synthesized gate-level netlist and finally a physical layout that implements exactly that operation.

<img width="1917" height="917" alt="Screenshot 2026-09-06 224553" src="https://github.com/user-attachments/assets/cf80ff97-4397-4090-a21f-b3b746bedd02" />

**Figure 3:** A single instruction traced from ISA definition to physical layout.

---

## 2️⃣ The Three Ingredients of Open-Source ASIC Design

An ASIC comes together from three ingredients:

<table>
<tr><td>📄 <b>RTL designs</b></td><td>The logic itself, often sourced from places like librecores.org, opencores.org, or GitHub</td></tr>
<tr><td>🛠️ <b>EDA tools</b></td><td>Qflow, OpenROAD, OpenLANE — the tools that turn RTL into a manufacturable layout</td></tr>
<tr><td>📚 <b>PDK data</b></td><td>Describes the target fabrication process</td></tr>
</table>

<img width="1596" height="910" alt="Screenshot 2026-09-06 224825" src="https://github.com/user-attachments/assets/a590f751-fbdf-4a01-a098-2fefe62ff953" />

**Figure 4:** RTL, EDA tools, and PDK data — the three pillars of an open-source ASIC flow.

---

## 3️⃣ What Exactly Is a PDK?

> 🧠 **Background:** In the early era of chip design, IC design was tightly coupled to whatever manufacturing process a given company had access to — whoever controlled the physics controlled the creative agenda. **Lynn Conway** and **Carver Mead** changed this by pioneering a structured design methodology based on λ-based design rules, which separated *design* from *technology* for the first time. That separation is what eventually made **Pure Play Fabs** (companies that only manufacture) and **Fabless design companies** (companies that only design) possible as distinct business models.

<img width="1537" height="923" alt="Screenshot 2026-09-06 224845" src="https://github.com/user-attachments/assets/e700b16f-e08a-4dc9-896d-5a94a39a1157" />

**Figure 5:** The Conway–Mead shift that separated design from fabrication.

A **Process Design Kit (PDK)** is the practical result of that separation — a collection of files that models a specific fabrication process for the EDA tools used to design an IC. It typically includes:

- 📏 Process design rules (DRC, LVS, PEX)
- ⚛️ Device models
- 🔲 Digital standard-cell libraries
- 🔌 I/O libraries

---

## 4️⃣ SKY130 — An Open-Source PDK

SKY130 is the PDK used throughout this program — a 130nm process, released as a fully open-source, production-grade PDK through a collaboration between **Google** and **SkyWater Technology**.

<img width="755" height="901" alt="Screenshot 2026-09-06 224901" src="https://github.com/user-attachments/assets/e1983181-504d-4d0b-a29e-c3cfc3f301ae" />


**Figure 6:** The SKY130 PDK.

> ✨ **Insight:** Its openness is what makes the rest of this program possible without any proprietary licensing — the same PDK data referenced by OpenLANE here is publicly available at `github.com/google/skywater-pdk`.

---

## 5️⃣ Surveying the EDA Tools Landscape

Turning RTL into a working chip involves far more individual steps than "synthesis" and "place and route" alone suggest.

<img width="1602" height="915" alt="Screenshot 2026-09-06 224917" src="https://github.com/user-attachments/assets/887cdb95-9b7a-4ab3-943f-487bbab50747" />


**Figure 7:** The full breadth of stages an EDA toolchain has to cover.

> Some of the stages an EDA toolchain has to cover: HDL simulation, HDL design entry, RTL synthesis, logic synthesis, floor planning, power planning, placement (global and detailed), clock tree synthesis, routing (global and detailed), RC extraction, static timing analysis, DRC, LVS, DFM, DFT, IR drop analysis, and static code/logic equivalence checking — usually each backed by its own specialized tool.

---

## 6️⃣ The RTL-to-GDSII Flow, Simplified

At a high level, all of that reduces to one pipeline: RTL and PDK data go in, and a **GDSII** file — the manufacturable layout — comes out, passing through synthesis, floorplanning/power planning, placement, clock tree synthesis, routing, and sign-off along the way.

<img width="1857" height="882" alt="Screenshot 2026-09-06 225131" src="https://github.com/user-attachments/assets/6a8348d2-b68b-4e9b-8646-d235548fcb73" />

**Figure 8:** The simplified RTL-to-GDSII pipeline.

<table>
<tr><td>🔨 <b>Synthesis</b></td><td><i>What:</i> Translates the behavioral RTL description into a gate-level netlist built entirely from cells available in the target standard-cell library.<br><i>Why:</i> RTL describes <i>what</i> the circuit should do, not the actual hardware that does it — synthesis commits to real, physically-implementable logic gates, the only thing later stages know how to work with.</td></tr>
<tr><td>📐 <b>Floorplanning & Power Planning</b></td><td><i>What:</i> Decides the chip's physical die dimensions, where major blocks and macros sit, and builds the power distribution network (rings, straps, rails) supplying every cell.<br><i>Why:</i> Every later stage depends on a fixed floorplan — placement can't run without knowing the available area, and cells can't function without a power network to connect to. Getting this wrong is expensive or impossible to fix later.</td></tr>
<tr><td>📍 <b>Placement</b></td><td><i>What:</i> Assigns every standard cell a specific (x, y) location — global placement (approximate positions optimizing wirelength) followed by detailed placement (legalizing onto the actual grid/rows).<br><i>Why:</i> Routing needs real cell coordinates to connect, and how well cells are placed relative to each other directly determines how short — or long and slow — the connecting wires will be.</td></tr>
<tr><td>🕐 <b>Clock Tree Synthesis (CTS)</b></td><td><i>What:</i> Builds a dedicated network of buffers/inverters distributing the clock signal from its source to every flip-flop in the design.<br><i>Why:</i> Clock skew — the clock reaching different flip-flops at different times — can break timing and cause functional failures. CTS delivers the clock everywhere with controlled, minimal skew, something a naive direct wire could never guarantee at scale.</td></tr>
<tr><td>🔌 <b>Routing</b></td><td><i>What:</i> Draws the actual metal wires implementing every electrical connection — global routing (coarse paths) followed by detailed routing (exact metal-layer, track-level geometry).<br><i>Why:</i> Placement only fixes <i>where</i> cells are — routing is what actually connects them, while respecting the PDK's manufacturing design rules so the layout can be fabricated correctly.</td></tr>
<tr><td>✅ <b>Sign-Off</b></td><td><i>What:</i> A final battery of checks on the completed layout — DRC, LVS, STA, and parasitic extraction (PEX) — confirming it's both manufacturable and functionally/timing-correct.<br><i>Why:</i> This is the last checkpoint before a design becomes an unchangeable, expensive-to-fix physical mask set — catching anything earlier stages missed while it's still fixable in software rather than silicon.</td></tr>
</table>

---

## 7️⃣ Meet OpenLANE

OpenLANE is an automated, open-source RTL-to-GDSII flow built specifically around the tools and PDK introduced above — it's the tool this program actually uses to walk that pipeline end-to-end.

### 🔗 7.1 What's Actually Chained Together Under the Hood

Underneath the simplified picture, OpenLANE chains together a specific set of tools for each stage: **Yosys + abc** for RTL synthesis, **OpenSTA** for static timing analysis, **Fault** for DFT, an **OpenROAD** application block handling floorplanning/placement/CTS/optimization/global routing, **TritonRoute** for detailed routing, and **Magic + Netgen** for physical verification and GDSII streaming — with a logic equivalence check (LEC) and a design-exploration loop feeding back into synthesis if results aren't good enough.

<img width="1641" height="916" alt="Screenshot 2026-09-06 225146" src="https://github.com/user-attachments/assets/0f9a8f92-844f-4cd9-8309-213021438b97" />


**Figure 9:** OpenLANE's detailed internal tool chain.

### 🧪 7.2 Design for Test (DFT)

Before physical implementation even begins, OpenLANE (via **Fault**) inserts test infrastructure into the design — scan insertion, automatic test pattern generation (ATPG), test pattern compaction, fault coverage, and fault simulation — so that manufactured chips can later be tested for defects.

<img width="1557" height="923" alt="Screenshot 2026-09-06 225209" src="https://github.com/user-attachments/assets/e9456140-7ca1-48df-87f1-543d919e87ce" />


**Figure 10:** DFT stages handled by Fault.

### 🏗️ 7.3 OpenROAD — Automated Place and Route

OpenROAD handles what's often just called automated PnR (Place and Route): floor/power planning, end decoupling capacitor and tap cell insertion, global and detailed placement, post-placement optimization, clock tree synthesis, and global and detailed routing.

<img width="1135" height="891" alt="Screenshot 2026-09-06 225221" src="https://github.com/user-attachments/assets/f57dbd43-febc-42fb-ad00-da9967d43522" />


**Figure 11:** OpenROAD's place-and-route stages.

### ⚡ 7.4 Handling Antenna Rule Violations

A subtle fabrication issue: a long metal wire segment can act as an antenna during manufacturing. Reactive ion etching causes charge to accumulate on the wire, and that accumulated charge can damage the transistor gate it eventually connects to before the rest of the circuit exists to safely discharge it.

<img width="1842" height="913" alt="Screenshot 2026-09-06 225235" src="https://github.com/user-attachments/assets/dbe3f839-a269-46d0-9b41-d4bf733b77df" />

**Figure 12:** The antenna effect during fabrication.

One fix is **bridging** — routing part of the net up to a higher metal layer and back down, which breaks the charge-accumulating path — though this requires router awareness that wasn't fully available at the time.

> ✨ **Insight:** OpenLANE instead takes a **preventive approach**: a fake antenna diode is added next to every cell input right after placement. The Antenna Checker (Magic) then runs on the routed layout, and only where it actually reports a violation does the fake diode get swapped for a real one — avoiding the cost of adding real diodes everywhere "just in case."

### 🔍 7.5 Design Space Exploration

Because so many flow parameters can be tuned, OpenLANE includes a **Design Space Exploration** utility to search for the best set of flow configurations for a given design, rather than requiring that tuning to be done by hand.

> It ships with a large number of reference examples to start from — 43 designs with known-good configurations at the time of this session, with more added over time.

---

## 8️⃣ Lab — Touring the SKY130 PDK Directory

With the concepts in place, the actual OpenLANE working directory was explored to see how the SKY130 PDK data is laid out on disk:

```bash
cd ~/Desktop/work/tools/openlane_working_dir
ls
cd pdks
ls
cd sky130A
ls
cd libs.ref
ls -ltr
```

<img width="1535" height="917" alt="Screenshot 2026-09-06 225527" src="https://github.com/user-attachments/assets/d52c750e-a16a-4a9d-b818-1b03cc6c094b" />

**Figure 13:** `libs.ref` directory contents under the SKY130 PDK.

> ✅ **Result:** `libs.ref` contains every SKY130 standard-cell flavor available — `sky130_fd_sc_hd` (high density, the one used throughout this workshop), along with `_hs`, `_ms`, `_ls`, `_hdll`, `_hvl`, `_lp` variants, plus `sky130_fd_io`, `sky130_sram_macros`, and `sky130_fd_pr`. Moving into `libs.tech` instead reveals the actual tool installations bundled with the PDK setup — `magic`, `netgen`, `klayout`, `ngspice`, `qflow`, `openlane`, `irsim`, `xschem`, and `xcircuit`.

---

## 9️⃣ Lab — Bringing Up OpenLANE

```bash
cd ..
docker run -it -v $(pwd):/openLANE_flow -v $PDK_ROOT:$PDK_ROOT -e PDK_ROOT=$PDK_ROOT -u $(id -u $USER):$(id -g $USER) efabless/openlane:v0.21
```

<img width="1712" height="917" alt="Screenshot 2026-09-06 225545" src="https://github.com/user-attachments/assets/d7d74d43-1553-4b5c-a7e5-aed5274f6b7e" />


**Figure 14:** OpenLANE Docker container starting up.

> ⚠️ **Result:** An existing shell alias (`docker` aliased to a `docker run ...` command) was also interfering with plain Docker commands like `docker images` — `unalias docker` was needed before the container could even be inspected properly. Once inside the container, `pwd` and `ls -ltr` confirmed the OpenLANE flow's actual top-level structure: `flow.tcl`, `run_designs.py`, the `designs/`, `scripts/`, `docker_build/`, and `configuration/` directories, and the top-level `README.md`.

---

## 🔟 Lab — Running `picorv32a` Through OpenLANE

With OpenLANE actually running, the next step was walking a real design — `picorv32a` — through the flow interactively, rather than just reading about each stage.

```bash
cd ~/Desktop/work/tools/openlane_working_dir/openlane
./flow.tcl -interactive
package require openlane 0.9
prep -design picorv32a
```

<img width="1737" height="902" alt="Screenshot 2026-09-06 225602" src="https://github.com/user-attachments/assets/f0d024b3-3dc2-48e5-b17c-e6aee055ca67" />


**Figure 15:** `prep -design picorv32a` output.

> ✨ **Insight:** `prep` sets up a timestamped run directory (`designs/picorv32a/runs/06-09_11-26` in this run) and merges the SKY130 LEF files, filler/tap/decap cell definitions, and clock buffer variants (`sky130_fd_sc_hd__clkbuf_1/2/4/8/16`) needed for the rest of the flow. It also loads the design's own config alongside per-library configs (`sky130A_sky130_fd_sc_hd_config.tcl` and its `_ms`/`_ls`/`_hs`/`_hdll` siblings) and the shared `floorplan.tcl`/`synthesis.tcl`/`cts.tcl`/`routing.tcl`/`placement.tcl` configuration files.

Exploring the resulting run directory:

```bash
cd designs/picorv32a
ls -ltr
cd src
ls -ltr
cd ../runs
ls -ltr
cd 06-09_11-26
ls -ltr
```

<img width="1706" height="907" alt="Screenshot 2026-09-06 225616" src="https://github.com/user-attachments/assets/f67d3fc4-eb0b-44d1-826b-aa52692455aa" />
bb-97d3-419d-ac6b-02d1319abbbd" />

**Figure 16:** `picorv32a` run directory listing.

<img width="1727" height="901" alt="Screenshot 2026-09-06 225632" src="https://github.com/user-attachments/assets/2c752eb0-644e-42ef-a0ef-5e4c50d1a064" />

**Figure 17:** Run directory contents continued.

> ✅ **Result:** This reveals the standard OpenLANE run layout: `PDK_SOURCES`, `tmp/`, `results/`, `reports/`, `OPENLANE_VERSION`, `cmds.log`, `logs/`, and `config.tcl` — every stage's output and logs are organized under this one timestamped folder.

Running synthesis:

```bash
run_synthesis
```

<img width="1771" height="920" alt="Screenshot 2026-09-06 225647" src="https://github.com/user-attachments/assets/8b756645-bc76-4796-ae2e-662a145bcdc8" />


**Figure 18:** `run_synthesis` output for `picorv32a`.

> ✅ **Result:** Synthesis invokes Yosys, which prints its GPL license banner and default corner libraries (`sky130_fd_sc_hd__ff_n40C_1v95.lib`, `sky130_fd_sc_hd__ss_100C_1v60.lib`) before generating SDC-style timing constraints from the environment — clock port and period, I/O delay values as a percentage of the clock period, a virtual clock for unclocked inputs, input/output delays, clock uncertainty, clock transition, and propagated clock settings. The run completed in about 13 seconds of user time with a 96.52 MB peak memory footprint, producing `results/synthesis/picorv32a.synthesis.v` — the synthesized gate-level netlist, whose module port list (`mem_instr`, `mem_ready`, `mem_addr`, `mem_wdata`, ... `pcpi_ready`, `irq`, `trace_valid`, `trace_data`) matches picorv32's actual memory and interrupt interface.

> ⚠️ **Note:** One warning surfaced during this run — a net reported as having **no driver** — a reminder that even a successful synthesis run is worth reading through for warnings, not just checking that it didn't error out.

Static timing analysis on the synthesized design surfaced a real critical path report, tracing a signal from a flip-flop (`sky130_fd_sc_hd__dfxtp_2`) forward through a chain of combinational cells — several `or2`/`or3`/`or4` gates, an `o22ai`, an `a221o`, and an `o2111a` — before reaching its endpoint, with the ideal clock network delay and each gate's pin-to-pin delay itemized along the way.

<img width="1716" height="877" alt="Screenshot 2026-09-06 225707" src="https://github.com/user-attachments/assets/ca2440a6-f342-4b3c-8da0-186160d4f907" />

**Figure 19:** STA critical path report.

> ✨ **Insight:** Running a real design through the flow interactively — rather than as one opaque batch command — makes each stage's actual output legible: the merged PDK data `prep` assembles, the constraints synthesis derives from the config, and the specific gates STA reports on the critical path.

---

## 🏁 Session Wrap-Up

- ✅ Traced the full chain from application software down to physical hardware, using RISC-V as a concrete example
- ✅ Understood the three ingredients of an open-source ASIC flow: RTL designs, EDA tools, and PDK data
- ✅ Learned what a PDK actually is, and the historical shift (Conway/Mead) that made separating design from fabrication possible in the first place
- ✅ Identified SKY130 as an open, production-grade PDK from Google and SkyWater
- ✅ Surveyed the breadth of the EDA tools landscape and how it collapses into a simplified RTL-to-GDSII flow
- ✅ Walked through OpenLANE's detailed internal flow, including DFT, OpenROAD-based PnR, antenna violation handling, and design space exploration
- ✅ Explored the actual SKY130 PDK directory structure and the tools bundled alongside it
- ⚠️ Hit and diagnosed real Docker setup issues (disk space, permissions, a conflicting alias) when first bringing up OpenLANE
- ✅ Ran `picorv32a` through `prep` and `run_synthesis` interactively, and read a real post-synthesis STA critical path report gate by gate
