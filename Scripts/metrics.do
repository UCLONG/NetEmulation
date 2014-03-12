# File: metrics.do
# Boris Dosen, UCL, March, 2014

# Metrics script for Network Emulation Simulation

for {set i 1} {$i <= 23} {incr i} {
vsim -G/NEMU_NetEmulation/LOAD=[expr {8+(4*$i)}] -G/NEMU_NetEmulation/sinks/fileNamePktRX="pktRX$i.txt" -G/NEMU_NetEmulation/sinks/fileNamePktTX="pktTX$i.txt" -G/NEMU_NetEmulation/sinks/fileNameTotalLatency="totalLatency$i.txt" work.NEMU_NetEmulation -do "onbreak {abort}; run -a;"
}

quit -sim