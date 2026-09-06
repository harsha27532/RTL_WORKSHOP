<div align="center">

# ⚡ Module 2 — Inside the Floorplan: Placement, Power Planning, and Clock Tree Synthesis

### *From Netlist to Layout: Giving Every Gate a Home*

<img src="https://img.shields.io/badge/Flow-OpenLane-9c27b0?style=for-the-badge&logo=opensourcehardware&logoColor=white" alt="OpenLane">
<img src="https://img.shields.io/badge/Tool-Magic-2196f3?style=for-the-badge&logo=icons8&logoColor=white" alt="Magic">
<img src="https://img.shields.io/badge/Tool-OpenROAD-673ab7?style=for-the-badge&logo=opensourcehardware&logoColor=white" alt="OpenROAD">
<img src="https://img.shields.io/badge/PDK-SKY130-e91e63?style=for-the-badge&logo=chip&logoColor=white" alt="SKY130">
<img src="https://img.shields.io/badge/Design-picorv32a-4caf50?style=for-the-badge&logo=riscv&logoColor=white" alt="picorv32a">

<br>

<img src="https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square">
<img src="https://img.shields.io/badge/Focus-Floorplan%20%26%20Placement-blueviolet?style=flat-square">
<img src="https://img.shields.io/badge/Deep%20Dive-Standard%20Cell%20Design-yellow?style=flat-square">

<sub>🔗 Part of the Chip Design Program — Physical Design series</sub>

</div>

---

## 📖 Overview

> 🟣 This module moves from synthesized gate-level netlists into the **physical design** stages of the ASIC flow: taking a netlist and turning it into a manufacturable layout.

It covers the theory behind chip floorplanning (core/die, utilization, preplaced cells, power planning, decoupling capacitors, pin placement), the placement and optimization steps that follow, the basics of library characterization (NLDM/CCS timing) that make timing-driven placement possible, an introduction to clock tree synthesis, and — one level below all of it — how the standard cells themselves are designed, from Euler's paths and stick diagrams down to SPICE-level characterization. A hands-on run of the OpenLane flow on the `picorv32a` design ties the theory to real floorplan, placement, and DRC output.

<table>
<tr><td>🛠️ <b>Tools used</b></td><td>OpenLane, OpenROAD, Magic, Yosys</td></tr>
<tr><td>🧩 <b>Example design</b></td><td><code>picorv32a</code> (RISC-V core)</td></tr>
<tr><td>📋 <b>Prerequisites</b></td><td>Module 1 (synthesis flow), basic familiarity with standard-cell libraries</td></tr>
</table>

## 🎯 Objectives

> 📐 Understand **core/die geometry**, utilization factor, and aspect ratio
> 🧩 Learn how **preplaced cells** and placement blockages shape a floorplan
> 🔋 Trace the **voltage-droop problem** and how decoupling capacitors solve it
> 📍 Distinguish **global placement** from legalized, timing-aware **detailed placement**
> 📊 Understand **NLDM/CCS timing models** and why they're built as lookup tables
> 🕐 Learn how **Clock Tree Synthesis** balances skew across every flip-flop
> 🔬 Go one level deeper — how a **standard cell itself** is designed and verified
> 🧪 Run OpenLane's **floorplan and placement** stages on `picorv32a`

---

## 📑 Table of Contents

| # | Section |
|:-:|---|
| 1️⃣ | [Laying Out the Chip: Floorplanning Basics](#1️⃣-laying-out-the-chip-floorplanning-basics) |
| 2️⃣ | [Placement — Rough Pass, Then Legal](#2️⃣-placement--rough-pass-then-legal) |
| 3️⃣ | [Timing Models and Clock Tree Synthesis](#3️⃣-timing-models-and-clock-tree-synthesis) |
| 4️⃣ | [One Level Deeper: How a Standard Cell Gets Built](#4️⃣-one-level-deeper-how-a-standard-cell-gets-built) |
| 5️⃣ | [Lab — Floorplan and Placement on picorv32a](#5️⃣-lab--floorplan-and-placement-on-picorv32a) |
| 🏁 | [Session Wrap-Up](#-session-wrap-up) |

---

## 1️⃣ Laying Out the Chip: Floorplanning Basics

### 🟦 1.1 Core and Die

<img width="1006" height="828" alt="Screenshot 2026-09-06 230433" src="https://github.com/user-attachments/assets/6577a91a-1b15-4ec7-b964-ebb351d6c2b3" />

**Figure 1:** Die vs. core boundary.

> Every chip is fabricated as one of many identical rectangles stepped across a **silicon wafer**. Each of those rectangles is the **die** — the full physical footprint of the chip, including scribe lines and I/O pads. Inside the die sits the **core** — the region where all logical cells (flip-flops, gates, etc.) are actually placed and routed. The gap between core and die boundary is reserved for I/O pads, ESD structures, and (as covered below) the power distribution network.

### 📐 1.2 Utilization Factor and Aspect Ratio

<img width="1416" height="887" alt="Screenshot 2026-09-06 230448" src="https://github.com/user-attachments/assets/6d1e76bb-2d0b-4016-9557-5bbb18ef0fd7" />


**Figure 2:** Utilization factor and aspect ratio.

Before anything is placed, floorplanning must fix the width and height of the core and die. Two derived quantities describe how "full" and how "square" that area is:

<table>
<tr><td>📊 <b>Utilization Factor</b></td><td>(Area occupied by logical cells) / (Total area of the core). 100% means the logic completely fills the core with no room left for routing — unrealistic in practice; real designs target well under 100% so the router has space to work with.</td></tr>
<tr><td>📏 <b>Aspect Ratio</b></td><td>Height / Width. A ratio of 1 gives a square core; values away from 1 give a rectangular one. Both numbers are chosen based on the design's cell count and the physical constraints of the target package.</td></tr>
</table>

### 🧩 1.3 Preplaced Cells

<img width="1096" height="898" alt="Screenshot 2026-09-06 230504" src="https://github.com/user-attachments/assets/6a1dbc06-2d75-433f-9ea5-fb1d08883a8c" />


**Figure 3:** Preplaced cells within the floorplan.

<img width="1361" height="898" alt="Screenshot 2026-09-06 230518" src="https://github.com/user-attachments/assets/66f4f92a-da66-496c-971f-297bd911cab4" />

**Figure 4:** Preplaced cells shown alongside the core boundary.

> Not everything in a design is a simple standard cell placed automatically. Larger, pre-designed functional blocks — memories, clock-gating cells, comparators, muxes, or any other hand-crafted/hard IP — are placed at **fixed, known locations** before automatic placement and routing begins. These are called **preplaced cells**, and the process of deciding where these IPs sit within the core is called **floorplanning**. Once their locations are fixed, the automated placement tool places the remaining standard cells around them, treating each preplaced block as a fixed obstacle it must route around.

### 🔋 1.4 Decoupling Capacitors and Power Planning

> 🧠 **Why decoupling capacitors are needed:** Every gate draws current from the shared Vdd/Vss power grid only when it switches. As you move away from the power supply pad, the metal wire supplying Vdd looks less like an ideal voltage source and more like a resistor-inductor (Rdd, Ldd) network in series with the actual supply. When a gate switches, it demands a short burst of current (**switching/peak current, I_peak**) — and drawing that current through a non-zero Rdd/Ldd causes the local voltage to sag momentarily. This is a **voltage droop / ground bounce** problem: shared rails, many switching cells, and non-ideal wire impedance combine to create transient noise on Vdd and Vss.

<img width="1791" height="478" alt="Screenshot 2026-09-06 230536" src="https://github.com/user-attachments/assets/dabf281b-48b8-4eef-9f6a-0a45339ba366" />


**Figure 5:** Voltage droop concept.

<img width="1512" height="897" alt="Screenshot 2026-09-06 230811" src="https://github.com/user-attachments/assets/b8435cb8-277d-452d-baf2-ca1b1e7a7409" />


**Figure 6:** The Rdd/Ldd network causing supply sag on switching.

> ⚠️ If enough gates switch simultaneously, the resulting dip or bump in the supply rail can cross into the **undefined region** between the valid logic-'1' threshold (Vih) and logic-'0' threshold (Vil) — a value neither reliably interpreted as a clean high nor a clean low. This is exactly the kind of noise that can flip a bit or cause a false transition.

> ✨ **Insight — decoupling capacitors (decaps):** A capacitor is placed in parallel with Vdd/Vss right next to the switching cells it protects. When a cell switches, the decap — already charged to Vdd — supplies the burst of current locally instead of forcing it to travel all the way back through the resistive/inductive supply network. The RC/RL network then has time to replenish the decap's charge before the next switching event, smoothing out the local supply.

<img width="1382" height="882" alt="Screenshot 2026-09-06 230833" src="https://github.com/user-attachments/assets/4d0949de-23d8-441e-8af8-9d0d640794cc" />

**Figure 7:** Decoupling capacitors placed within the floorplan.

<img width="1288" height="908" alt="Screenshot 2026-09-06 230854" src="https://github.com/user-attachments/assets/f614eb56-9314-4e60-8f26-14ed44882099" />


**Figure 8:** Decap cells (DECAP1, DECAP2, DECAP3) shown alongside logic.

> Physically, decaps are placed as their own cells around the preplaced blocks, right alongside the other logic.

> 🔌 **Power planning:** Beyond individual decaps, the whole core needs a robust **power distribution network (PDN)** — a mesh of horizontal and vertical Vdd/Vss straps overlaid across the die so every cell has a short, low-resistance path to the supply, no matter where it sits.

<img width="1375" height="886" alt="Screenshot 2026-09-06 230916" src="https://github.com/user-attachments/assets/a2bee391-6a42-4889-9611-904b36b1071f" />

**Figure 9:** Power distribution network (PDN) mesh across the die.

> This mesh is what the decaps tie into, and it is also why power planning happens early in floorplanning: routing tracks for both signal and power need to be reserved before cell placement gets dense.

### 📍 1.5 Pin Placement

<img width="1557" height="887" alt="Screenshot 2026-09-06 230933" src="https://github.com/user-attachments/assets/fc298240-1d36-4292-a951-95f4221f6db9" />


**Figure 10:** Pin placement around the die/core boundary.

> With preplaced blocks and the power mesh fixed, the input/output pins of the design (`Din1..4`, `Dout1..4`, `Clk1`, `Clk2`, `ClkOut`, etc.) are assigned physical locations around the die/core boundary. Pin placement affects how easily signals can later be routed to and from the core logic, so pins are typically placed close to whichever internal block they connect to most directly.

### 🚫 1.6 Logical Cell Placement Blockage

<img width="1163" height="906" alt="Screenshot 2026-09-06 230948" src="https://github.com/user-attachments/assets/3a708f0c-bcca-47bd-8db6-4ec00a99c668" />


**Figure 11:** Placement blockage marked over preplaced cells and the power mesh.

> ✅ **Result:** A **placement blockage** is marked over the regions already occupied by preplaced cells and the power mesh, telling the automatic placer "don't put any standard cells here." Once pins, preplaced blocks, decaps, and the power mesh are all fixed and blockages are marked, the floorplan is considered ready for the placement and routing step.

---

## 2️⃣ Placement — Rough Pass, Then Legal

### 🌐 2.1 Global Placement

Once the floorplan (core/die size, preplaced cells, power mesh, pins) is fixed, the **placer** takes every standard cell in the synthesized netlist and assigns it an approximate location within the available rows of the core. This first pass — **global placement** — optimizes primarily for wirelength and cell density, without yet guaranteeing that every cell sits on a legal, non-overlapping row position.

### 🎯 2.2 Optimized (Detailed) Placement

<img width="1817" height="887" alt="Screenshot 2026-09-06 231242" src="https://github.com/user-attachments/assets/92bf644d-0d1d-462d-81fa-657c17c17b64" />

**Figure 12:** Detailed placement — cells legalized onto rows and site grid.

> ✨ **Insight:** **Detailed placement** legalizes the rough global-placement result: cells are snapped onto actual placement rows and site grid, overlaps are removed, and the tool re-optimizes locally for timing and wirelength based on estimated interconnect delay. This is also where the timing engine starts to matter — the placer needs to know how much delay and capacitance each net will add once wires are drawn, which is exactly what library characterization (next section) provides.

---

## 3️⃣ Timing Models and Clock Tree Synthesis

### 📊 3.1 NLDM, CCS Timing, and Power Characterization

<img width="1342" height="423" alt="Screenshot 2026-09-06 231253" src="https://github.com/user-attachments/assets/48418549-a8a2-4748-a171-ac9695d1b7e9" />

**Figure 13:** NLDM-style lookup table concept.

Every timing-driven step in the flow — placement, CTS, routing, static timing analysis — depends on knowing, for every cell in the library, how its delay and output slew change with input slew and output load. Two common modeling styles capture this:

<table>
<tr><td>📋 <b>NLDM</b> (Non-Linear Delay Model)</td><td>Represents a cell's delay and output transition time as two-dimensional lookup tables indexed by input transition time and output load capacitance. Compact and fast to use — the traditional basis for <code>.lib</code> (Liberty) timing arcs.</td></tr>
<tr><td>⚡ <b>CCS</b> (Composite Current Source)</td><td>Models a cell's output as an equivalent current source rather than a simple RC delay, capturing waveform shape more accurately (especially for noise and crosstalk analysis) at the cost of larger characterization data.</td></tr>
</table>

> ✨ **Insight:** Both are produced by **characterizing** each cell across a sweep of input slews and output loads in SPICE, then distilling the results into the lookup tables a synthesis/STA tool consumes — this is the same kind of `.lib` data referenced when Yosys selected `sky130_fd_sc_hd__mux2_1` in earlier modules; here the emphasis is on where that data comes from and why it's structured as lookup tables rather than closed-form equations.

### 🕐 3.2 Clock Tree Synthesis (CTS)

> After placement, every flip-flop's clock pin needs to receive the clock signal at (ideally) the same time — minimizing **clock skew** — while also controlling **insertion delay**. Rather than routing one long wire from the clock source to every flip-flop (which would have wildly different delays to near vs. far flip-flops), **Clock Tree Synthesis** builds a balanced tree of buffers/inverters so that every leaf of the tree — every flip-flop clock pin — sees a comparable delay from the root.

> ✨ **Insight:** Balancing this tree is itself a placement-and-routing-aware problem: CTS runs after initial placement is known, precisely because it needs real physical distances to size and place its buffers correctly.

---

## 4️⃣ One Level Deeper: How a Standard Cell Gets Built

Everything above treats standard cells (an AND gate, a DFF, a buffer) as fixed, pre-characterized building blocks. This section looks one level deeper: how is a single standard cell itself designed?

<img width="1680" height="897" alt="Screenshot 2026-09-06 231309" src="https://github.com/user-attachments/assets/ee66700f-6ea9-46ce-b32e-62d527453b5a" />


**Figure 14:** Standard cell design flow overview.

### 📥 4.1 Inputs to Cell Design

A cell designer starts from three kinds of inputs, all supplied by the foundry as part of the **Process Design Kit (PDK)**:

<table>
<tr><td>📏 <b>Process design rules</b> (DRC/LVS)</td><td>The geometric constraints a layout must obey to be manufacturable (minimum widths, spacings, extensions), and the rules for verifying the layout matches the intended schematic</td></tr>
<tr><td>⚛️ <b>SPICE models</b></td><td>Transistor-level models (like BSIM parameters) used to simulate the cell's electrical behavior before committing to layout</td></tr>
<tr><td>📋 <b>Cell specification</b></td><td>The logic function, input/output pin arrangement, and target drive strength the new cell needs to implement</td></tr>
</table>

<img width="1556" height="805" alt="Screenshot 2026-09-06 231323" src="https://github.com/user-attachments/assets/fc5f199a-7cc6-4714-9b81-2e36b1b48206" />

**Figure 15:** SPICE/BSIM transistor model parameters.

### 🔬 4.2 Circuit Design and Characterization

The designer first builds and simulates the transistor-level circuit (e.g. sizing PMOS/NMOS ratios for a target switching threshold Vm), then, once the circuit works, characterizes it — measuring delay, power, and noise-margin behavior across process/voltage/temperature corners — the same NLDM/CCS characterization discussed above, but here it's the source data being generated rather than consumed.

### 🖊️ 4.3 Layout: Euler's Path and Stick Diagrams

<img width="1550" height="891" alt="Screenshot 2026-09-06 231335" src="https://github.com/user-attachments/assets/34568b3e-451b-4227-aabd-9c8c7fe18a9f" />


**Figure 16:** Euler's path found across the PMOS and NMOS transistor graphs.

<img width="1381" height="806" alt="Screenshot 2026-09-06 231345" src="https://github.com/user-attachments/assets/0f25d4e2-d713-4314-80b5-84cce4d4f09f" />


**Figure 17:** Stick diagram — the intermediate layout abstraction.

> ✨ **Insight:** Translating a transistor-level schematic into a compact layout starts with graph theory: the PMOS network and NMOS network of a complex gate (e.g. `(B+D).(A+C)+E.F`) are each represented as a graph, and an **Euler's path** — a path that traverses every edge of the graph exactly once — is found that is *common* to both the PMOS and NMOS graphs. Following that shared Euler's path when placing transistors lets the polysilicon gate strips run in one continuous, non-broken line across the cell, which directly minimizes the diffusion breaks needed and keeps the resulting layout compact. The **stick diagram** is the intermediate abstraction between this graph and the final layout: it shows relative placement and connectivity of poly, diffusion, and metal without yet committing to exact dimensions.

### ✅ 4.4 DRC, LVS, and Parasitic Extraction

> Layout dimensions are specified in units of **lambda (λ)**, defined as half the minimum feature size (λ = L/2, where L is the process's minimum gate length). Expressing rules this way (e.g. "poly width: 2λ", "poly-to-active spacing: 1λ") lets the same design rules scale automatically if the process's minimum feature size changes. Once a layout is drawn, it must pass:

<table>
<tr><td>📏 <b>DRC</b> (Design Rule Check)</td><td>Verifying every geometric constraint (widths, spacings, extensions) from the PDK's rule deck is satisfied</td></tr>
<tr><td>🔍 <b>LVS</b> (Layout vs. Schematic)</td><td>Verifying the layout's extracted netlist matches the original transistor-level schematic</td></tr>
</table>

> ✅ **Result:** Only after clearing both is the cell considered ready to be added to the standard-cell library that the rest of the flow (synthesis, placement, CTS, routing) will draw from.

---

## 5️⃣ Lab — Floorplan and Placement on `picorv32a`

With the theory in place, the same steps were run through OpenLane on the `picorv32a` RISC-V core design.

```bash
cd ~/Desktop/work/tools/openlane_working_dir/openlane
# inside the OpenLane flow shell
```

<img width="1717" height="892" alt="Screenshot 2026-09-06 231404" src="https://github.com/user-attachments/assets/3a9ce098-ff87-4381-810f-691353aab756" />


**Figure 18:** OpenLane flow shell, `picorv32a` context.

The flow's `floorplan` step reports the die/core geometry it computed (visible as repeated `STEP 460 0 ;` DEF placement-grid entries) before writing out `picorv32a.floorplan.def`:

```bash
cd designs/picorv32a/runs/06-09_11-26/results/floorplan
ls -ltr
less picorv32a.floorplan.def
```

<img width="1722" height="898" alt="Screenshot 2026-09-06 231427" src="https://github.com/user-attachments/assets/aeae307e-8d49-4c41-bdf5-581b7ea4c18f" />


**Figure 19:** `picorv32a.floorplan.def` contents.

Opening the resulting floorplan in **Magic** (with DRC checking enabled) shows the die outline with rows ready for placement:

<img width="1592" height="893" alt="Screenshot 2026-09-06 231442" src="https://github.com/user-attachments/assets/a94e0d89-4700-4abd-82ba-6153d106f236" />

**Figure 20:** Floorplan viewed in Magic.

<img width="1201" height="830" alt="Screenshot 2026-09-06 231728" src="https://github.com/user-attachments/assets/8a4c9195-8140-4f82-97cd-2630fbd53807" />

**Figure 21:** Floorplan in Magic, zoomed detail.

Running the placement stage next produces a denser, gate-level view of the same design once cells have been dropped into rows and legalized:

<img width="1292" height="782" alt="Screenshot 2026-09-06 231738" src="https://github.com/user-attachments/assets/1e61aa4e-2a23-4f2b-9f95-e0ff9e9638c7" />


**Figure 22:** Placement result viewed in Magic.

<img width="1350" height="868" alt="Screenshot 2026-09-06 231746" src="https://github.com/user-attachments/assets/30409a87-c0e4-433d-a2c0-ca5ce4531029" />

**Figure 23:** Placement result, zoomed detail.

> ✅ **Result:** The floorplan and placement stages both completed cleanly on `picorv32a`, with the resulting DEF and layout views matching the theory covered in Sections 1–2.

---

## 🏁 Session Wrap-Up

- ✅ Learned the core/die distinction and how utilization factor and aspect ratio govern how floorplanning sizes the core
- ✅ Understood preplaced cells (memory, clock-gating cells, comparators, muxes) as fixed obstacles placed before automatic placement, and floorplanning as the process of arranging them
- ⚡ Traced the voltage-droop/ground-bounce problem to non-ideal Rdd/Ldd in the power network, and saw decoupling capacitors and power-mesh planning as the fix
- ✅ Covered pin placement and placement blockages as the final steps that mark a floorplan ready for placement and routing
- 🎯 Distinguished global placement (rough, wirelength-optimized) from detailed placement (legalized, timing-aware)
- 📊 Learned why NLDM and CCS timing models exist — lookup-table representations of characterized cell delay/slew behavior that timing-driven placement and CTS depend on
- 🕐 Understood Clock Tree Synthesis as building a balanced buffer tree to minimize clock skew across flip-flops
- 🔬 Went one level below the standard-cell abstraction: how a cell itself is designed, from PDK inputs and SPICE characterization through Euler's-path-driven stick diagrams to DRC/LVS-clean layout
- ✅ Ran the OpenLane flow's floorplan and placement stages on `picorv32a`, inspecting the resulting DEF files and layouts directly in Magic
