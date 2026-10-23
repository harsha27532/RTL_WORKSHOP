
# 🌊 Flood Alert Controller — RTL to GDS

A Verilog-based Flood Alert Controller implemented using **OpenROAD Flow Scripts (ORFS)** and the **Sky130HD** technology platform.

## 📌 Project Overview

This project implements a digital flood alert controller that monitors water-level inputs and supports alert-level escalation with rate-of-rise detection. The design is taken through the RTL-to-GDS physical-design flow.

## ✨ Features

- Verilog RTL implementation
- Water-level monitoring and alert escalation
- Floorplanning and standard-cell placement
- Clock-tree synthesis (CTS)
- Global and detailed routing
- Physical-design visualization and report generation
- DRC and LVS verification

## 🛠️ Tools & Technologies

- **HDL:** Verilog
- **Physical Design:** OpenROAD Flow Scripts (ORFS)
- **Technology Platform:** Sky130HD
- **Layout Format:** GDSII

## 📁 Project Structure

```text
flood_alert/
├── rtl/
│   └── flood_alert.v
├── tb/
├── gls/
├── physical_design/
├── final_deliverables/
│   └── flood_alert.gds
├── docs/
│   └── images/
├── reports/
└── README.md
```

## 🖼️ Physical Design Flow — Visual Results

### 1. Floorplanning

![Initial Floorplan](docs/images/2_1_floorplan.webp)

![Final Floorplan](docs/images/final_floorplan.webp)

### 2. Standard-Cell Placement

![Global Placement](docs/images/3_global_place.webp)

![Final Placement](docs/images/final_placement.webp)

### 3. Clock-Tree Synthesis (CTS)

![Final Clock Tree](docs/images/final_clocks.webp)

![CTS Layout](docs/images/cts_tt_100C_1v80_clk_layout.webp)

### 4. Routing

![Global Routing](docs/images/5_global_route.webp)

![Final Routing](docs/images/final_routing.webp)

### 5. Congestion Analysis

![Final Congestion](docs/images/final_congestion.webp)

### 6. IR-Drop Analysis

![IR Drop](docs/images/final_ir_drop.webp)

### 7. Timing Analysis

![Worst Timing Path](docs/images/final_worst_path.webp)

![Resizer Results](docs/images/final_resizer.webp)

## 📊 Verification Results

| Check | Result |
|---|---|
| DRC | 0 reported violations |
| LVS | Netlists matched successfully |
| Hold Timing | No violations reported |
| Setup Timing | Not yet closed |

## ⏱️ Timing Summary

- **Clock Period:** 10 ns
- **Worst Negative Slack (WNS):** Approximately −2.70 ns
- **Total Negative Slack (TNS):** Approximately −24.25 ns
- **Setup Violations:** 15

> **Note:** The physical-design flow completed and generated a final GDSII layout. However, setup timing closure has not been achieved, so the design is not timing-clean for signoff.

## 📦 Final Deliverable

The generated layout is available at:

[`final_deliverables/flood_alert.gds`](final_deliverables/flood_alert.gds)

## 🚀 Future Improvements

- Optimize critical-path timing
- Add and run a dedicated RTL testbench
- Perform gate-level simulation
- Re-run timing analysis after optimization

---

**Project:** Flood Alert Controller  
**Flow:** RTL-to-GDS using OpenROAD  
**Platform:** Sky130HD
