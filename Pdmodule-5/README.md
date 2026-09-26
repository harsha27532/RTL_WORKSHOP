<div align="center">

# ⚡ Module 5 — Wiring It All Up: Routing, DRC, Power Distribution, and Parasitic Extraction

### *From Route Guides to GDSII: Connecting Every Net Correctly*

<img src="https://img.shields.io/badge/Flow-OpenLane%20%2F%20OpenROAD-4caf50?style=for-the-badge&logo=opensourcehardware&logoColor=white" alt="OpenLane / OpenROAD">
<img src="https://img.shields.io/badge/Routing-TritonRoute-673ab7?style=for-the-badge&logo=opensourcehardware&logoColor=white" alt="TritonRoute">
<img src="https://img.shields.io/badge/STA-OpenSTA-ff9800?style=for-the-badge&logo=icons8&logoColor=white" alt="OpenSTA">
<img src="https://img.shields.io/badge/PDK-SKY130-2196f3?style=for-the-badge&logo=chip&logoColor=white" alt="SKY130">
<img src="https://img.shields.io/badge/Verification-DRC-e91e63?style=for-the-badge&logo=icons8&logoColor=white" alt="DRC">
<img src="https://img.shields.io/badge/Format-LEF%20%2F%20DEF%20%2F%20SPEF-9c27b0?style=for-the-badge&logo=icons8&logoColor=white" alt="LEF / DEF / SPEF">

<br>

<img src="https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square">
<img src="https://img.shields.io/badge/Focus-Routing%20%26%20PDN-blueviolet?style=flat-square">
<img src="https://img.shields.io/badge/Output-GDSII--Ready-yellow?style=flat-square">

<sub>🔗 Part of the SKY130 VLSI Physical Design module series</sub>

</div>

---

## 📖 Overview

> 🟣 This document covers Module 5 of the SKY130 physical-design flow: global and detailed routing, maze routing via Lee's Algorithm, Power Distribution Network (PDN) construction, Design Rule Checking (DRC), TritonRoute's detailed-routing engine, routing connectivity and topology, parasitic extraction/SPEF generation, and the resulting OpenLane output used for post-route timing verification.

<table>
<tr><td>🛠️ <b>Tools used</b></td><td>OpenLane, OpenROAD, TritonRoute, OpenSTA, Yosys, SKY130 PDK, Magic, LEF, DEF, SPEF, Tcl, Docker</td></tr>
<tr><td>🧩 <b>Example design(s)</b></td><td>OpenLane-driven SKY130 physical design run (routing, PDN and DRC labs)</td></tr>
<tr><td>📋 <b>Prerequisites</b></td><td>OpenLane/OpenROAD environment running in Docker, SKY130 PDK installed, a placed and clock-tree-synthesized design, LEF/DEF files available</td></tr>
</table>

## 🎯 Objectives

> 🗺️ Distinguish **global routing** (approximate paths) from **detailed routing** (real wires and vias)
> 🧩 Trace **Lee's Algorithm** and its wavefront-expansion approach to maze routing
> 🔋 Build and configure a **Power Distribution Network** — rings, straps, rails, macro connections
> 📏 Apply **DRC checks** for wire width, via spacing, and overall layout cleanliness
> 🔨 Understand how **TritonRoute** resolves intra-layer and inter-layer routing
> 🔗 Learn **Access Points**, obstacles, and routing-topology optimization
> ⚡ Extract post-route **parasitics into SPEF** and verify timing with OpenSTA
> 🏁 Connect the **full RTL-to-GDSII flow** end to end

---

## 📑 Table of Contents

| # | Section |
|:-:|---|
| 1️⃣ | [Routing Fundamentals: Global, Fast, and Detailed](#1️⃣-routing-fundamentals-global-fast-and-detailed) |
| 2️⃣ | [Maze Routing — Lee's Algorithm](#2️⃣-maze-routing--lees-algorithm) |
| 3️⃣ | [Power Distribution Network (PDN)](#3️⃣-power-distribution-network-pdn) |
| 4️⃣ | [Design Rule Checking (DRC)](#4️⃣-design-rule-checking-drc) |
| 5️⃣ | [Inside TritonRoute's Detailed-Routing Engine](#5️⃣-inside-tritonroutes-detailed-routing-engine) |
| 6️⃣ | [Routing Connectivity and Topology](#6️⃣-routing-connectivity-and-topology) |
| 7️⃣ | [Parasitic Extraction and SPEF Generation](#7️⃣-parasitic-extraction-and-spef-generation) |
| 8️⃣ | [Running the Flow in OpenLane](#8️⃣-running-the-flow-in-openlane) |
| 9️⃣ | [Post-Route Timing Verification and Final Checklist](#9️⃣-post-route-timing-verification-and-final-checklist) |
| 🔟 | [The Full RTL-to-GDSII Flow](#🔟-the-full-rtl-to-gdsii-flow) |
| 1️⃣1️⃣ | [Tools and Technologies Used](#1️⃣1️⃣-tools-and-technologies-used) |
| 🏁 | [Session Wrap-Up](#-session-wrap-up) |

---

## 1️⃣ Routing Fundamentals: Global, Fast, and Detailed

### 🗺️ 1.1 Routing Overview and Objectives

Routing connects placed standard cells, pins, and other components through the metal layers while satisfying design rules. It proceeds through global routing, fast routing, detailed routing, design-rule-aware routing, and connectivity verification.

<img width="1666" height="790" alt="Routing overview" src="https://github.com/user-attachments/assets/630ae945-356e-44a6-9bda-23ee3480dc1c" />

**Figure 1:** Routing stages overview.

### ⚖️ 1.2 Global Routing vs. Detailed Routing

<table>
<tr><td>🌐 <b>Global routing</b></td><td>Divides the routing region into a resource grid and finds approximate paths through it, producing route guides for the detailed-routing stage. Goals: estimate routing paths, manage congestion, allocate routing resources, spot bottlenecks, and generate guides.</td></tr>
<tr><td>🔌 <b>Detailed routing</b></td><td>Turns those approximate paths into actual wire segments and vias, working at the level of exact wire locations, layer selection, via placement, design rules, connectivity, and local congestion.</td></tr>
</table>

<div align="center">

| Feature | Global Routing | Detailed Routing |
|---|---|---|
| Purpose | Approximate routing paths | Actual physical connections |
| Representation | Routing resource grid | Physical wires and vias |
| Output | Routing guides | Detailed routed geometry |
| Main concern | Congestion and resource allocation | Connectivity and design-rule compliance |
| Level of detail | Coarse | Fine-grained |

</div>

### 🏃 1.3 Fast Route and Route Guide Generation

<div align="center">

| Stage | Description |
|---|---|
| **Fast Route** | Produces an initial routing solution and generates route guides |
| **Detailed Route** | Converts that initial routing information into physical routing that satisfies detailed design rules |

</div>

<img width="1548" height="828" alt="Fast route and route guide generation" src="https://github.com/user-attachments/assets/3c6cf241-2146-4ce6-933b-1b1607a1f793" />

**Figure 2:** Fast Route output and generated route guides.

---

## 2️⃣ Maze Routing — Lee's Algorithm

Maze routing is a grid-based pathfinding technique for connecting two points while avoiding obstacles. **Lee's Algorithm** does this through wavefront expansion: it explores neighboring grid cells in successive steps, assigning distance values, until it reaches the destination, then backtracks to reconstruct the shortest path.

### 🔢 2.1 Algorithm Steps

1. Mark the source point as the starting location
2. Expand the wavefront — explore neighboring grid cells and assign distance values
3. Exclude blocked or unavailable locations (obstacle avoidance)
4. Continue expanding until the destination is reached
5. Backtrack along the minimum-distance path
6. Record the final reconstructed route

<img width="1653" height="822" alt="Lee's Algorithm wavefront expansion" src="https://github.com/user-attachments/assets/5bcb9ea8-8663-4d5c-8293-59b965e2ceb2" />

**Figure 3:** Lee's Algorithm — wavefront expansion and backtracking.

### ⚖️ 2.2 Advantages and Limitations

<table>
<tr><td>✅ <b>Advantages</b></td><td>Systematic path exploration; guarantees the shortest valid path in an unweighted grid when one exists; naturally handles obstacles by excluding blocked cells; a simple foundation for understanding maze routing.</td></tr>
<tr><td>⚠️ <b>Limitations</b></td><td>Memory-intensive for large grids; can explore many unnecessary locations; doesn't inherently account for congestion, wire delay, or layer preference — real VLSI routing needs those factored in on top.</td></tr>
</table>

---

## 3️⃣ Power Distribution Network (PDN)

### 🔋 3.1 Purpose and Components of the PDN

A PDN distributes power and ground throughout the design, supplying standard cells and macros while keeping voltage levels acceptable. It aims to:

- Distribute power and ground across the chip
- Connect standard cells and macros electrically
- Reduce voltage drop along power paths
- Support current delivery to every region of the design
- Structure the connection between the power source and circuit components

> Typical components: power/ground pins, power rings, power straps, standard-cell power rails, macro power connections, and vias linking power conductors across metal layers.

### ⚙️ 3.2 PDN Construction Flow and Configuration

```text
Power and Ground Definition
          |
          v
Power Ring Generation
          |
          v
Power Strap Generation
          |
          v
Power Rail Connection
          |
          v
Standard-Cell and Macro Connections
          |
          v
Power Connectivity Verification
```

> ✨ **Insight:** In OpenROAD-based flows, PDN generation is scripted in Tcl — e.g. a `pdngen` invocation triggers the configured power-network generation process, with the actual power nets, layers, and geometry defined for the specific design and technology.

<img width="1262" height="847" alt="PDN construction in OpenROAD" src="https://github.com/user-attachments/assets/4ea6ea50-6fcc-41bb-bca7-e125f4270eee" />

**Figure 4:** PDN construction via `pdngen`.

### 🔌 3.3 Power Straps and Standard-Cell / Macro Power Connections

<table>
<tr><td>🔲 <b>Power straps</b></td><td>Wider metal conductors that distribute power/ground across the core, connecting into the PDN and carrying current to cells and macros via designated layers and vias.</td></tr>
<tr><td>📏 <b>Standard cells</b></td><td>Draw power/ground through their power pins and the rails running along their placement rows, which the PDN connects into the broader power network.</td></tr>
<tr><td>🧱 <b>Macros</b> (e.g. RAM blocks)</td><td>May need dedicated power pins; the PDN must connect these to the chip-level power network.</td></tr>
</table>

> Key PDN-design factors: metal-layer selection, strap width/spacing, via connectivity, current demand, voltage drop, macro placement/pin locations, and rail-to-network connectivity.

---

## 4️⃣ Design Rule Checking (DRC)

DRC verifies that a physical layout satisfies the fabrication rules of the chosen technology — geometry restrictions that keep the design manufacturable.

### 📏 4.1 Common Design Rules

- Minimum wire width
- Minimum spacing between wires and between vias
- Minimum enclosure and area requirements
- Layer-specific restrictions
- Connectivity constraints, and restrictions on overlapping/improperly connected shapes

> A DRC violation surfaces when a route breaks a spacing, width, enclosure, or other physical constraint — routing and verification stages exist to find and resolve these.

### 📐 4.2 DRC — Wire Width

Wires thinner than the minimum allowed width can violate manufacturing rules and hurt interconnect reliability.

<img width="865" height="406" alt="Wire width DRC check" src="https://github.com/user-attachments/assets/221df795-50eb-4b06-aa01-7efde6b247eb" />

**Figure 5:** Wire-width DRC check.

### 🔗 4.3 DRC — Via Spacing

Correct spacing between vias and neighboring structures prevents manufacturing violations and unintended shorts.

<img width="847" height="422" alt="Via spacing DRC check" src="https://github.com/user-attachments/assets/768aeb48-1c2b-4366-a976-0e66f08f7e76" />

**Figure 6:** Via-spacing DRC check.

### ✅ 4.4 A DRC-Clean Layout

A **DRC-clean** result means the layout satisfies every rule checked under the verification conditions used — though that alone doesn't confirm timing, electrical connectivity, or antenna requirements are also met.

<img width="1243" height="587" alt="DRC-clean layout result" src="https://github.com/user-attachments/assets/3b3f5884-415b-4b44-8c65-abd10da8ad32" />

**Figure 7:** DRC-clean layout result.

---

## 5️⃣ Inside TritonRoute's Detailed-Routing Engine

### 🔨 5.1 Role of TritonRoute and Routing Configuration

TritonRoute is the detailed-routing engine in the OpenROAD flow. It turns route guides into actual physical connections while respecting routing constraints and design rules — processing guides, connecting pins, routing across metal layers, handling obstacles, resolving conflicts, and enforcing design-rule compliance.

```text
Global Routing → Routing Guides → TritonRoute → Detailed Wire/Via Generation → Routing Verification → Post-Route Design
```

> An illustrative OpenROAD command for this stage is `detailed_route`, invoked with the design and routing configuration already loaded; exact options depend on the installed OpenROAD version and flow configuration.

<img width="1471" height="543" alt="TritonRoute invocation" src="https://github.com/user-attachments/assets/88e06beb-0b6b-4b02-92e2-bab8309a78b1" />

**Figure 8:** `detailed_route` invocation in TritonRoute.

<img width="1600" height="953" alt="TritonRoute detailed routing result" src="https://github.com/user-attachments/assets/a3eaaa84-156d-4c64-bec6-7c5f3ce6116c" />

**Figure 9:** Detailed routing result from TritonRoute.

### 🗺️ 5.2 Preprocessed Route Guides

Route guides mark the preferred regions/directions for routing a net, generated during global routing to steer detailed routing toward the paths chosen earlier. Requirements: guides should have unit width and follow the preferred routing direction.

> Guides help by providing direction, making use of allocated routing resources, coordinating global and detailed routing, and cutting down unnecessary exploration.

<img width="1296" height="837" alt="Preprocessed route guides, part 1" src="https://github.com/user-attachments/assets/5c6913f1-a94e-43e4-9787-e8bd15956e91" />

**Figure 10:** Preprocessed route guides.

<img width="1600" height="948" alt="Preprocessed route guides, part 2" src="https://github.com/user-attachments/assets/dc1e8be6-618b-466f-b258-f9fbcf776703" />

**Figure 11:** Route guides steering detailed routing.

<img width="1600" height="951" alt="Preprocessed route guides, part 3" src="https://github.com/user-attachments/assets/5d1ade17-624e-4332-8f14-6bd8731ac023" />

**Figure 12:** Route guide detail view.

### 🔀 5.3 Intra-Layer and Inter-Layer Routing

<div align="center">

| Strategy | Description |
|---|---|
| **Intra-Layer (Parallel)** | Connections handled within the same metal layer; multiple routing tasks processed in parallel |
| **Inter-Layer (Sequential)** | Routing proceeds sequentially across layers, using vias to connect conductors, for full connectivity |

</div>

<img width="1342" height="711" alt="Intra-layer and inter-layer routing" src="https://github.com/user-attachments/assets/d3a2fc47-b364-40ec-9596-4332b3eb87d0" />

**Figure 13:** Intra-layer vs. inter-layer routing strategies.

A typical multi-layer connection looks like:

```text
Source Pin → Metal Layer 1 → Via → Metal Layer 2 → Via → Destination Pin
```

---

## 6️⃣ Routing Connectivity and Topology

### 📍 6.1 Access Points and Access Point Clusters

<table>
<tr><td><b>Access Point (AP)</b></td><td>An on-grid point on a route guide's metal layer, used to connect lower-layer segments, upper-layer segments, pins, or I/O ports.</td></tr>
<tr><td><b>Access Point Cluster (APC)</b></td><td>The union of access points that all derive from the same lower-layer segment, upper-layer guide, pin, or I/O port.</td></tr>
</table>

<img width="1466" height="770" alt="Access points and access point clusters" src="https://github.com/user-attachments/assets/b6ca48bf-67f9-4a84-9bf3-2c5e6a0888cc" />

**Figure 14:** Access Points and Access Point Clusters.

### 🚧 6.2 Routing Obstacles and Optimization

> **Obstacles** restrict where wires/vias can go — macro blockages, existing routed wires, restricted regions, spacing constraints, and pin-access limits all count. The detailed router must route around these while keeping every net's terminals fully connected — an open connection or incomplete route is a connectivity failure.

> **Routing optimization** then improves the physical connections without breaking connectivity, weighing wirelength, congestion, design-rule compliance, via count, signal delay, and routing-resource use.

<img width="1600" height="951" alt="Routing obstacles, part 1" src="https://github.com/user-attachments/assets/56df0f41-ff0e-4e71-b900-99b97423cff1" />

**Figure 15:** Routing around obstacles.

<img width="1600" height="950" alt="Routing obstacles, part 2" src="https://github.com/user-attachments/assets/35ca128c-19d5-4f28-bffd-0e34ad27be24" />

**Figure 16:** Routing optimization result.

### 🧮 6.3 The Routing Topology Algorithm

The routing-topology algorithm decides how a multi-terminal net's connection points link together efficiently — minimizing routing cost while keeping every terminal connected. The physical router then implements that topology as actual wire segments and vias, respecting all routing constraints; topology choice affects wirelength, resource use, and parasitic characteristics.

<img width="836" height="415" alt="Routing topology algorithm" src="https://github.com/user-attachments/assets/28a669c5-7aaa-431c-85b3-a31d0020e67a" />

**Figure 17:** Routing topology for a multi-terminal net.

---

## 7️⃣ Parasitic Extraction and SPEF Generation

After routing, the resistance, capacitance, interconnect delay, and coupling effects introduced by the physical wires must be extracted for accurate post-layout timing analysis.

<img width="1790" height="806" alt="Parasitic extraction overview" src="https://github.com/user-attachments/assets/9f4e1314-915a-4091-9054-4a13111b6d9c" />

**Figure 18:** Parasitic extraction overview.

> **SPEF** (Standard Parasitic Exchange Format) carries this extracted parasitic information — resistance, capacitance, nets, interconnect parasitics, and connectivity — generated by an extraction script that processes the routed DEF.

<img width="951" height="595" alt="SPEF generation, part 1" src="https://github.com/user-attachments/assets/55e26362-e2cc-45a8-82f3-882e027d695f" />

**Figure 19:** SPEF file generation.

<img width="1600" height="952" alt="SPEF generation, part 2" src="https://github.com/user-attachments/assets/5c0d0e40-24c0-4c7f-a990-be4a7c9bae14" />

**Figure 20:** Extracted parasitic data.

---

## 8️⃣ Running the Flow in OpenLane

### 📐 8.1 Floorplanning and Power Planning

Key floorplanning elements: core/die area, standard-cell rows, I/O placement, power rings and straps, and macro placement — all set up to ensure reliable VPWR/VGND distribution.

<img width="1247" height="720" alt="Floorplanning and power planning" src="https://github.com/user-attachments/assets/421a8ef1-0340-460c-b2b3-47a15ca4600d" />

**Figure 21:** Floorplan with power planning applied.

### ⚙️ 8.2 OpenLane Configuration Parameters

Configuration parameters span placement, CTS, routing, Magic, density, timing, and routing optimization — controlling cell density, clock-tree generation, routing layers/optimization, and layout generation.

<img width="1900" height="840" alt="OpenLane configuration parameters" src="https://github.com/user-attachments/assets/73e6d019-9a93-4fca-b285-e9462edb16e9" />

**Figure 22:** OpenLane configuration parameters.

### 📂 8.3 Routing Output and Run Directories

<img width="1600" height="953" alt="Routing output directory structure" src="https://github.com/user-attachments/assets/2472fec6-b465-4fbe-b881-0b2e4fa5e62a" />

**Figure 23:** Routing output.

Synthesis and routing results are organized into stage-specific run directories:

```text
results/
├── synthesis/
├── routing/
├── placement/
├── cts/
├── floorplan/
└── signoff/
```

---

## 9️⃣ Post-Route Timing Verification and Final Checklist

<img width="1600" height="956" alt="Post-route timing verification" src="https://github.com/user-attachments/assets/c746c647-edfd-475e-9354-6f06d62653c4" />

**Figure 24:** Post-route timing verification in OpenSTA.

> **OpenSTA** evaluates post-route timing using the routed netlist, SDC constraints, and extracted parasitics, computing arrival time, required time, and setup/hold slack:

```text
Routed Netlist
      |
      v
Timing Constraints (SDC)
      |
      v
Parasitic Information
      |
      v
OpenSTA
      |
      v
Arrival Time and Required Time
      |
      v
Setup and Hold Slack
      |
      v
Timing Verification
```

**Final implementation checklist:**

- [ ] Power distribution network generated
- [ ] Global routing completed
- [ ] Detailed routing completed
- [ ] Routing connectivity checked
- [ ] Design rule checking performed
- [ ] Parasitic information generated
- [ ] Post-route timing analysis performed
- [ ] Final physical design files generated

---

## 🔟 The Full RTL-to-GDSII Flow

```text
RTL Design
 ↓
Synthesis
 ↓
Floorplanning
 ↓
Power Distribution Network
 ↓
Standard-Cell Placement
 ↓
Clock Tree Synthesis
 ↓
Global Routing
 ↓
Fast Route / Route Guide Generation
 ↓
Route Guide Preprocessing
 ↓
Detailed Routing (TritonRoute)
 ↓
Design Rule Checking
 ↓
Parasitic Extraction / SPEF Generation
 ↓
Post-Route Timing Analysis (OpenSTA)
 ↓
Physical Verification
 ↓
GDSII
```

---

## 1️⃣1️⃣ Tools and Technologies Used

<div align="center">

| Tool / Technology | Purpose |
|---|---|
| OpenLane | Automated RTL-to-GDSII physical design flow |
| OpenROAD | Physical implementation and optimization |
| TritonRoute | Design-rule-aware detailed routing engine |
| OpenSTA | Static Timing Analysis |
| Yosys | RTL synthesis |
| SKY130 | Open-source 130 nm process technology |
| Magic | Layout viewing and physical verification |
| LEF | Physical cell and technology information |
| DEF | Physical design placement/routing representation |
| SPEF | Standard Parasitic Exchange Format |
| Tcl | Flow configuration and automation |
| Docker | Execution environment |

</div>

---

## 🏁 Session Wrap-Up

- 🗺️ Understood how global routing (resource grid, route guides) differs from detailed routing (actual wires and vias)
- 🧩 Traced Lee's Algorithm's wavefront-expansion approach to maze routing, along with its memory/congestion trade-offs
- 🔋 Built and configured a Power Distribution Network — rings, straps, rails, and macro power connections — via `pdngen`
- 📏 Applied DRC checks for wire width, via spacing, and overall layout cleanliness
- 🔨 Learned how TritonRoute consumes LEF/DEF/route guides and resolves intra-layer and inter-layer routing to produce a wirelength/via-optimized solution
- 🔗 Understood connectivity handling through Access Points and Access Point Clusters, and how routing topology balances cost against full connectivity
- ⚡ Extracted post-route parasitics into SPEF and used OpenSTA for post-route setup/hold timing verification
- 🏁 Connected the full flow: **PDN → Global Routing → Detailed Routing (TritonRoute) → DRC → Parasitic Extraction → Post-Route STA → GDSII**
