<div align="center">

# ⚡ Module 3 — Building a CMOS Inverter: From SPICE Circuit to Silicon Layout

### *One Standard Cell, Start to Finish: Design, Fabricate, Lay Out, Verify, Characterize*

<img src="https://img.shields.io/badge/PDK-SKY130A-e91e63?style=for-the-badge&logo=chip&logoColor=white" alt="SKY130A">
<img src="https://img.shields.io/badge/Simulator-ngspice-ff9800?style=for-the-badge&logo=icons8&logoColor=white" alt="ngspice">
<img src="https://img.shields.io/badge/Layout-Magic%20VLSI-4caf50?style=for-the-badge&logo=opensourcehardware&logoColor=white" alt="Magic VLSI">
<img src="https://img.shields.io/badge/Format-SPICE-9c27b0?style=for-the-badge&logo=icons8&logoColor=white" alt="SPICE">
<img src="https://img.shields.io/badge/Verification-DRC-2196f3?style=for-the-badge&logo=icons8&logoColor=white" alt="DRC">

<br>

<img src="https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square">
<img src="https://img.shields.io/badge/Focus-Standard%20Cell%20Design-blueviolet?style=flat-square">
<img src="https://img.shields.io/badge/Flow-Fabrication%20to%20Characterization-yellow?style=flat-square">

<sub>🔗 Part of the SKY130 VLSI Physical Design module series</sub>

</div>

---

## 📖 Overview

> 🟣 This document covers Module 3 of the SKY130 VLSI design flow: designing, simulating, laying out, extracting, and characterizing a **CMOS inverter** standard cell.

It follows the complete path from a transistor-level SPICE circuit through the Voltage Transfer Characteristic (VTC) and switching-threshold analysis, into the 16-mask CMOS fabrication process, a Magic-based standard-cell layout, Design Rule Checking (DRC), SPICE extraction, and final post-layout characterization using ngspice.

<table>
<tr><td>🛠️ <b>Tools used</b></td><td>ngspice, Magic VLSI, SKY130A PDK, SPICE/NGSPICE, Git &amp; GitHub, Linux terminal</td></tr>
<tr><td>🧩 <b>Example design(s)</b></td><td>CMOS inverter standard cell (<code>vsdstdcelldesign</code>)</td></tr>
<tr><td>📋 <b>Prerequisites</b></td><td>SKY130 PDK installed, Magic and ngspice set up, basic MOSFET/CMOS theory, Git installed</td></tr>
</table>

## 🎯 Objectives

> 🔌 Design and simulate a **transistor-level CMOS inverter** in SPICE/ngspice
> 📈 Generate the **VTC** and identify the switching threshold Vm, both by simulation and analytically
> 📏 Study how **transistor sizing** affects Vm, drive strength, and timing
> 🏭 Walk through the **16-mask CMOS fabrication process**, layer by layer
> 🖊️ Build a real **standard-cell layout** in Magic using SKY130A technology files
> ✅ Run **DRC**, interpret violations as geometrical constructs, and resolve them
> 🔍 Extract a **SPICE netlist** directly from the physical layout
> 🧪 Perform **post-layout characterization** and confirm `Output = NOT(Input)`

---

## 📑 Table of Contents

| # | Section |
|:-:|---|
| 1️⃣ | [Circuit-Level Design: The CMOS Inverter in SPICE](#1️⃣-circuit-level-design-the-cmos-inverter-in-spice) |
| 2️⃣ | [Reading the VTC and Finding the Switching Threshold](#2️⃣-reading-the-vtc-and-finding-the-switching-threshold) |
| 3️⃣ | [Static vs. Dynamic Analysis](#3️⃣-static-vs-dynamic-analysis) |
| 4️⃣ | [How a CMOS Inverter Is Actually Fabricated](#4️⃣-how-a-cmos-inverter-is-actually-fabricated) |
| 5️⃣ | [Building the Standard-Cell Layout in Magic](#5️⃣-building-the-standard-cell-layout-in-magic) |
| 6️⃣ | [Design Rule Checking (DRC)](#6️⃣-design-rule-checking-drc) |
| 7️⃣ | [Extracting SPICE From the Layout](#7️⃣-extracting-spice-from-the-layout) |
| 8️⃣ | [Post-Layout Characterization in ngspice](#8️⃣-post-layout-characterization-in-ngspice) |
| 9️⃣ | [The Full Module 3 Flow, End to End](#9️⃣-the-full-module-3-flow-end-to-end) |
| 🔟 | [Tools and Technologies Used](#🔟-tools-and-technologies-used) |
| 🏁 | [Session Wrap-Up](#-session-wrap-up) |

---

## 1️⃣ Circuit-Level Design: The CMOS Inverter in SPICE

A CMOS inverter consists of a PMOS transistor (connected to VDD) and an NMOS transistor (connected to GND/VSS), with their gates tied together to form the input and their drains tied together to form the output.

```text
             VDD
              |
             PMOS
              |
Vin ----------|------ Vout
              |
             NMOS
              |
             GND
```

### 📝 1.1 Building the SPICE Deck

The SPICE deck contains transistor definitions, SKY130A device models, circuit connections, the power supply, an input stimulus, simulation commands, and measurement statements. The initial transistor dimensions used were:

$$W_n = W_p = 0.375\mu m, \quad L_n = L_p = 0.25\mu m$$

giving $W_n/L_n = W_p/L_p = 1.5$.

<img width="1512" height="841" alt="Screenshot 2026-09-26 225654" src="https://github.com/user-attachments/assets/4831a933-30b9-44b0-8b1b-1aae78b8ed7d" />

**Figure 1:** CMOS inverter SPICE deck.

### ⚡ 1.2 DC and Transient Simulation

The circuit was simulated in ngspice to observe input voltage, output voltage, current, and switching behavior. The inverter operates through complementary switching:

<table>
<tr><td><b>Vin is LOW</b></td><td>PMOS is ON, NMOS is OFF → <b>Vout is HIGH</b></td></tr>
<tr><td><b>Vin is HIGH</b></td><td>NMOS is ON, PMOS is OFF → <b>Vout is LOW</b></td></tr>
<tr><td><b>Transition region</b></td><td>Both transistors influence the output</td></tr>
</table>

<img width="1465" height="797" alt="Screenshot 2026-09-26 230008" src="https://github.com/user-attachments/assets/ec0aa9c1-26c2-4938-ade8-34d1ffe4543e" />


**Figure 2:** DC/transient simulation results.

---

## 2️⃣ Reading the VTC and Finding the Switching Threshold

### 📈 2.1 Generating the VTC

The VTC represents $V_{out} = f(V_{in})$ and can be divided into three regions: HIGH output, transition, and LOW output. During the HIGH region $V_{out} \approx V_{DD}$, and during the LOW region $V_{out} \approx 0$. The steep transition region indicates high voltage gain around the switching point.

<img width="1068" height="857" alt="Screenshot 2026-09-26 230024" src="https://github.com/user-attachments/assets/0c26998d-a2c4-442b-8ec8-7647f7df24ec" />


**Figure 3:** Voltage Transfer Characteristic (VTC).

### 🎯 2.2 The Switching Threshold, Vm

The switching threshold **Vm** is the input voltage at which $V_{in} = V_{out}$, i.e. where the inverter transitions between logic states. Key VTC parameters are:

<div align="center">

| Parameter | Meaning |
|:-:|---|
| VOH | Output High Voltage |
| VOL | Output Low Voltage |
| VIH | Input High Voltage |
| VIL | Input Low Voltage |
| Vm | Switching Threshold |

</div>

> ✅ **Result:** Observed values across different sizing configurations were approximately **Vm ≈ 0.98 V** and **Vm ≈ 1.2 V**.

<img width="1060" height="546" alt="Screenshot 2026-09-26 230147" src="https://github.com/user-attachments/assets/ff261f06-f24c-4511-89aa-a172c9159265" />

**Figure 4:** Vm measured directly from the simulated VTC.

> ✨ **Insight:** Vm can also be derived analytically from the relative drive strengths of the NMOS/PMOS devices, considering $W_n/L_n$, $W_p/L_p$, $K_n$, $K_p$, saturation voltage, and device threshold parameters.

<img width="1112" height="528" alt="Screenshot 2026-09-26 230212" src="https://github.com/user-attachments/assets/ecff9e5b-8535-465c-ae12-840a8b38dadd" />


**Figure 5:** Analytical derivation of Vm.

### ⚖️ 2.3 How Transistor Sizing Shifts Vm

Two configurations were compared:

<div align="center">

| Config | $W_n/L_n$ | $W_p/L_p$ | $W_p$ |
|:-:|:-:|:-:|:-:|
| 1 | 1.5 | 1.5 | 0.375 µm |
| 2 | 1.5 | 3.75 | 0.9375 µm |

</div>

> ✨ **Insight:** Increasing PMOS width increases its relative drive strength, shifting the switching threshold and changing the timing characteristics.

<img width="1092" height="560" alt="Screenshot 2026-09-26 232630" src="https://github.com/user-attachments/assets/0398248f-dcaf-4c42-822b-be35a35dd629" />

**Figure 6:** VTC for sizing configuration 1.

<img width="1087" height="568" alt="Screenshot 2026-09-26 232644" src="https://github.com/user-attachments/assets/4ff346b4-0168-4fdc-8104-bd9619055b3b" />


**Figure 7:** VTC for sizing configuration 2 — the shifted Vm is visible.

---

## 3️⃣ Static vs. Dynamic Analysis

<table>
<tr><td>📊 <b>Static analysis</b></td><td>Studies DC characteristics: VOH, VOL, VIH, VIL, Vm, noise margins, and the DC transfer curve (VTC).</td></tr>
<tr><td>⏱️ <b>Dynamic analysis</b></td><td>Studies time-dependent behavior: propagation delay, rise time, fall time, charging/discharging behavior, and dynamic power consumption — important because standard cells must meet timing at the target operating frequency.</td></tr>
</table>

---

## 4️⃣ How a CMOS Inverter Is Actually Fabricated

The physical implementation of a standard cell is built through a sequence of fabrication steps that define what each layout layer physically represents.

### 🏝️ 4.1 Active Region Formation (LOCOS)

The active region defines where transistor source/drain regions are formed — NMOS in the P-type region, PMOS inside the N-well. The process used is **LOCOS (Local Oxidation of Silicon)**, involving a P-type substrate, silicon nitride masking, photoresist, field oxide, and the resulting bird's-beak effect, used to isolate active regions from surrounding silicon.

<img width="1113" height="548" alt="Screenshot 2026-09-26 232708" src="https://github.com/user-attachments/assets/ed5d79ca-86a5-4f34-a143-acfdf291cd4c" />

**Figure 8:** Active region formation via LOCOS.

### 🌊 4.2 N-Well and P-Well Formation

Ion implantation creates the N-well (where PMOS is formed) and P-well (where NMOS is formed), establishing the correct body environment, isolation, and substrate biasing for CMOS operation.

<img width="1162" height="565" alt="Screenshot 2026-09-26 232722" src="https://github.com/user-attachments/assets/dfc57278-4ac3-4f29-a253-6b05e92b24ba" />


**Figure 9:** N-well and P-well formation.

### 🔬 4.3 Threshold Voltage and the Body Effect

MOS threshold voltage depends on:

<table>
<tr><td>$V_{T0}$</td><td>Threshold voltage at zero body bias</td></tr>
<tr><td>$\gamma$</td><td>Body-effect coefficient</td></tr>
<tr><td>$V_{SB}$</td><td>Source-to-body voltage</td></tr>
<tr><td>$\Phi_F$</td><td>Fermi potential</td></tr>
<tr><td>$N_A$</td><td>Doping concentration</td></tr>
<tr><td>$C_{ox}$</td><td>Oxide capacitance</td></tr>
</table>

<img width="1217" height="570" alt="Screenshot 2026-09-26 232823" src="https://github.com/user-attachments/assets/77b75748-9983-4135-be4e-45b151f93723" />

**Figure 10:** Threshold voltage and body-effect relationships.

### 🚪 4.4 Gate Formation

Polysilicon deposited over the active region forms the gate; the poly/active intersection forms the channel. In a CMOS inverter, the PMOS and NMOS gates are tied together to form the input, and the drains are tied together to form the output.

<img width="890" height="445" alt="Gate formation, part 1" src="https://github.com/user-attachments/assets/89f69fe6-423d-489d-9b08-c60f4edcb58c" />

**Figure 11:** Polysilicon gate formation.

<img width="842" height="450" alt="Gate formation, part 2" src="https://github.com/user-attachments/assets/048d71fe-b49f-4526-aadc-89595b62d00a" />

**Figure 12:** Gate structure over the channel region.

### 🧱 4.5 LDD Formation and Side-Wall Spacers

Lightly Doped Drain (LDD) regions near the source/drain reduce the electric field at the drain, improving reliability and hot-carrier performance. Phosphorus implantation is used to set the required doping profile, followed by side-wall spacer formation, which sets the separation between the gate and the later heavily-doped source/drain regions.

<img width="786" height="447" alt="LDD formation, part 1" src="https://github.com/user-attachments/assets/4f51d807-8cee-432d-99ee-e6ba352bc88a" />

**Figure 13:** LDD implantation.

<img width="897" height="447" alt="LDD formation, part 2" src="https://github.com/user-attachments/assets/16b7cbc3-e4ff-46f7-9b93-fe9616ef82cd" />

**Figure 14:** Side-wall spacer formation.

<img width="778" height="447" alt="LDD formation, part 3" src="https://github.com/user-attachments/assets/e25d18c2-dca9-4657-a090-6aa26f756777" />

**Figure 15:** Spacer structure detail.

### 🔩 4.6 Source and Drain Formation

Final source/drain regions are formed by high-temperature doping — N-type for NMOS, P-type for PMOS — completing the basic transistor structure:

```text
        Gate
         │
    ┌────┴────┐
    │ Channel │
────┴─────────┴────
 Source       Drain
```

<img width="936" height="467" alt="Source and drain formation" src="https://github.com/user-attachments/assets/213dded3-a0af-459f-8f52-0ad12b97d7a8" />

**Figure 16:** Completed source/drain regions.

### 🔗 4.7 Contacts and Local Interconnect

Titanium is sputtered onto the wafer to prepare low-resistance connections, followed by contact formation linking source, drain, and gate to the local interconnect layer — turning isolated transistors into electrically accessible devices.

<img width="777" height="443" alt="Contact formation, part 1" src="https://github.com/user-attachments/assets/98a09a5c-e270-4d5d-a287-d4f45d3f1028" />

**Figure 17:** Titanium sputtering and contact prep.

<img width="811" height="445" alt="Contact formation, part 2" src="https://github.com/user-attachments/assets/5a9b2fb3-7baf-4b4a-9368-1cebc5d78a19" />

**Figure 18:** Contacts linking transistors to local interconnect.

### 🏗️ 4.8 Higher-Level Metal and the Completed Structure

Higher-level metal layers route signals, VDD, and VSS across the chip and connect individual cells into a complete circuit network.

<img width="848" height="451" alt="Higher-level metal routing" src="https://github.com/user-attachments/assets/e5ac4cdf-b0b2-4fcc-82d1-805e7ce9b785" />

**Figure 19:** Higher-level metal routing.

<img width="635" height="433" alt="Completed CMOS inverter structure" src="https://github.com/user-attachments/assets/b04a3796-a970-4c11-991b-65ab2009116f" />

**Figure 20:** Completed CMOS inverter cross-section.

---

## 5️⃣ Building the Standard-Cell Layout in Magic

### 📥 5.1 Cloning the Design Repository

```bash
git clone <repository-url>
cd <repository-directory>
```

> The cloned `vsdstdcelldesign` repository provides the starting environment for the layout and characterization flow.

### ⚙️ 5.2 Loading SKY130 Technology Files

Magic requires the SKY130A technology file (`sky130A.tech`) to correctly interpret layer names, connectivity, design rules, and DRC/extraction rules.

<img width="1600" height="950" alt="Loading SKY130 technology file in Magic, part 1" src="https://github.com/user-attachments/assets/845d0ed6-ca4c-4630-adc5-839ac943e7f0" />

**Figure 21:** Loading the SKY130A technology file in Magic.

<img width="1600" height="1003" alt="Loading SKY130 technology file in Magic, part 2" src="https://github.com/user-attachments/assets/d8c1f33e-b167-4fd0-bcd3-441660a44b42" />

**Figure 22:** Magic session with SKY130A layers active.

### 🔲 5.3 Cell Boundary, Power, and Ground Connectivity

> A cell boundary defines the exact width/height occupied by the cell, ensuring consistent dimensions, accurate placement, alignment with neighboring cells, and correct VDD/GND rail locations for library compatibility.

VDD and GND rails are then connected: the PMOS network toward VDD and the NMOS network toward GND, matching the pull-up/pull-down structure of the inverter.

### 🖼️ 5.4 The Finished Layout and Its Abstract View

The completed layout contains the PMOS/NMOS transistors, input/output pins, VDD/VSS connections, well/tap structures, and metal routing, built using SKY130 layers (active/diffusion, poly, contact, metal1/2, N-well, implant, and tap layers).

<img width="1600" height="949" alt="Completed CMOS inverter layout in Magic" src="https://github.com/user-attachments/assets/8aacbd4a-50e4-4fd3-bddc-2eeed4cd1412" />

**Figure 23:** Completed CMOS inverter layout in Magic.

> ✨ **Insight:** An **abstract view** (LEF — Library Exchange Format) provides a simplified physical representation containing cell dimensions, pin locations/names, routing layers, obstructions, and placement information, without full transistor geometry.

---

## 6️⃣ Design Rule Checking (DRC)

### 📏 6.1 DRC Concepts and Common Rules

DRC verifies that a layout satisfies the physical design rules of the technology before it can be considered valid. Common rule types include:

- Minimum width
- Minimum spacing
- Minimum enclosure
- Minimum overlap
- Minimum extension
- Layer-specific spacing requirements

<img width="693" height="865" alt="DRC rule types reference" src="https://github.com/user-attachments/assets/9cb0cc71-c60c-462f-b3ca-072edb586d3d" />

**Figure 24:** Common DRC rule types.

### 🔧 6.2 Fixing the `poly.9` DRC Error

Debugging flow used for the `poly.9` violation:

1. Identify the reported DRC location
2. Inspect the affected geometry in Magic
3. Understand the rule associated with the error
4. Determine the required geometrical relationship
5. Modify the layout or the relevant technology rule
6. Re-run DRC and verify the error is resolved

### 📐 6.3 Poly Resistor Spacing to Diffusion and Tap

> This exercise checks the minimum spacing between polysilicon resistor structures, diffusion regions, and tap regions — incorrect spacing here produces DRC violations, so the layout must meet SKY130's minimum spacing rules.

### 🔍 6.4 Treating DRC Errors as Geometrical Puzzles

Rather than treating a DRC error as just a message, it should be analyzed as a geometrical violation by identifying: the affected layers, their geometrical relationship, the required rule condition, the actual layout condition, and the needed correction.

<img width="1600" height="947" alt="DRC error analyzed as geometrical construct" src="https://github.com/user-attachments/assets/71ded9d7-0289-4ac5-b453-bec84074ca8c" />

**Figure 25:** A DRC violation analyzed geometrically in Magic.

---

## 7️⃣ Extracting SPICE From the Layout

### 🔄 7.1 The Extraction Flow

```text
Circuit Design
      ↓
Physical Layout
      ↓
DRC Verification
      ↓
SPICE Extraction
      ↓
Extracted SPICE Netlist
      ↓
Simulation
```

> Extraction identifies the transistors, connections, nodes, device parameters, and parasitic components implied by the physical geometry, converting it into an electrical (SPICE-compatible) representation.

<img width="882" height="855" alt="SPICE extraction flow diagram" src="https://github.com/user-attachments/assets/07db20c5-d8a9-4b3f-828f-8fece6df6223" />

**Figure 26:** SPICE extraction flow.

### 📄 7.2 The Extracted Netlist

The extracted `.ext`/SPICE files are generated and inspected, then combined with SKY130 model files and a standard-cell subcircuit definition (input/output nodes, VDD, GND) into a simulation-ready SPICE deck.

<img width="1600" height="953" alt="Extracted netlist, part 1" src="https://github.com/user-attachments/assets/fb092721-f8ac-422e-a1e4-84210e0b3bd1" />

**Figure 27:** Extracted netlist contents.

<img width="1600" height="947" alt="Extracted netlist, part 2" src="https://github.com/user-attachments/assets/1530d294-cf8e-4a01-93b5-bd30e57ee0a5" />

**Figure 28:** Final simulation-ready SPICE deck assembled from the extraction.

---

## 8️⃣ Post-Layout Characterization in ngspice

### 🧪 8.1 Transient Simulation of the Extracted Netlist

The extracted netlist is simulated in ngspice with a time-varying input while monitoring Input, Output, VDD, and GND to verify correct connectivity and switching behavior.

<img width="1600" height="951" alt="Transient simulation setup" src="https://github.com/user-attachments/assets/f5e4238c-9524-49ca-9e1c-4c97488902e9" />

**Figure 29:** Transient simulation of the extracted netlist.

<img width="1600" height="945" alt="Transient simulation running" src="https://github.com/user-attachments/assets/a67648d4-360e-4dd8-b082-ad9ffc9f0278" />

**Figure 30:** ngspice transient run in progress.

### 📊 8.2 Input/Output Waveforms

<div align="center">

| Input | Output |
|:-:|:-:|
| LOW | HIGH |
| HIGH | LOW |

</div>

<img width="1600" height="949" alt="Input/output waveform confirming inverter behavior" src="https://github.com/user-attachments/assets/07966352-3fef-4048-8e26-8238a008cb9b" />

**Figure 31:** Post-layout input/output waveform.

> ✅ **Result:** The fundamental relationship confirmed is **Output = NOT(Input)**, with the output approaching the expected VDD/GND levels.

### ⏱️ 8.3 Timing and Parasitic Effects

> ✨ **Insight:** Extracted parasitic elements (from real layout geometry) can influence propagation delay, rise time, fall time, and output transition speed — making post-layout simulation more realistic than an ideal schematic-level simulation. Key timing parameters tracked: rise time, fall time, propagation delay, and input/output transition time.

---

## 9️⃣ The Full Module 3 Flow, End to End

```text
                    SKY130 MODULE 3
                           |
                           ↓
              CMOS Inverter Design
                           |
                           ↓
                 SPICE Deck Creation
                           |
                           ↓
                  ngspice Simulation
                           |
                           ↓
                Switching Threshold Vm
                           |
                           ↓
             Static & Dynamic Analysis
                           |
                           ↓
                 Sky130 PDK Models
                           |
                           ↓
              CMOS Fabrication Process
                           |
                           ↓
                 Magic Layout Design
                           |
                           ↓
              Standard Cell Layout
                           |
                           ↓
                 DRC Verification
                           |
                           ↓
              SPICE Netlist Extraction
                           |
                           ↓
               Inverter Characterization
                           |
                           ↓
                    LEF Generation
                           |
                           ↓
              Standard Cell Library
```

---

## 🔟 Tools and Technologies Used

<div align="center">

| Tool / Technology | Purpose |
|---|---|
| ngspice / NGSPICE | CMOS circuit simulation and characterization |
| Magic VLSI | Layout creation, editing, DRC, and SPICE extraction |
| SKY130A PDK | Technology rules, device models, and design information |
| SPICE | Circuit-level simulation |
| Git & GitHub | Version control, repository management, documentation |
| LEF | Abstract physical representation of standard cells |
| DRC | Physical design-rule verification |
| SKY130 Model Files | Device-level simulation and characterization |
| Standard Cell Library | Reusable digital logic cells |

</div>

---

## 🏁 Session Wrap-Up

- ✅ Understood the working principle of a CMOS inverter through complementary PMOS/NMOS switching
- ✅ Built and simulated a transistor-level CMOS inverter using SPICE and ngspice
- ✅ Generated the VTC and identified the switching threshold Vm both from simulation and analytically
- ⚖️ Studied how transistor sizing ($W/L$ ratios) affects Vm, drive strength, and timing
- 🏭 Learned the 16-mask CMOS fabrication sequence — from LOCOS active-region formation through wells, gate, LDD, source/drain, contacts, and metallization
- 🖊️ Created a CMOS inverter standard-cell layout in Magic using SKY130A technology files, including cell boundary and power/ground connectivity
- 🔧 Ran DRC, interpreted violations (including the `poly.9` error) as geometrical constructs, and resolved them
- 🔍 Extracted a SPICE netlist directly from the physical layout and generated an LEF abstract view
- ✅ Performed post-layout ngspice transient simulation, verifying `Output = NOT(Input)` and studying parasitic/timing effects
- 🔗 Connected the full flow: **Simulation → Fabrication Understanding → Layout → DRC → Extraction → Characterization → Standard Cell Library**, forming a foundation for RTL-to-GDSII physical design
