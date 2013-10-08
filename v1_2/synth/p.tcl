
# Power estimation using Primetime-PX
# pt_shell -gui

set DESIGN_NAME "alloc_simple" 

set power_enable_analysis TRUE

set target_library "./kit/typ.db"
set link_library "* ./kit/typ.db"

read_db $target_library

#read_verilog ../ic/run/results/alloc_islip.routed.v
read_verilog results/$DESIGN_NAME.mapped.v
current_design "$DESIGN_NAME"
link_design

read_parasitics -format spef results/$DESIGN_NAME.mapped.spef

create_clock -name clk -period 1.5 clk 

#set power_analysis_mode time_based
#read_vcd -rtl vcs/alu.vcd -strip_path test/DUT
# .out format (for RTL VCD waveform_interval option will be ignored)
#set_power_analysis_options -waveform_output wave -waveform_format out

read_vcd -rtl vcd/netemulation.vcd -strip_path net_emulation/inst_net/inst_alloc -time {1100 2100}
report_power > reports/$DESIGN_NAME.power.txt

exit
