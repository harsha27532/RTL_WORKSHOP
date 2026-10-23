export DESIGN_NAME=flood_alert
export PLATFORM=sky130hd

export VERILOG_FILES=$(DESIGN_DIR)/src/flood_alert.v
export SDC_FILE=$(DESIGN_DIR)/constraint.sdc

export CLOCK_PORT=clk
export CLOCK_PERIOD=10
export  CORE_UTILIZATION = 20
export CORE_MARGIN = 10
