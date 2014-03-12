# File: batchAnalysis.do
# Boris Dosen, UCL, March, 2014

# BatchAnalysis script for Network Emulation Simulation

for {set i 1} {$i <= 10} {incr i} {
vsim -G/NEMU_NetEmulation/SEED=[expr int(rand()*10000)] -G/NEMU_NetEmulation/sinks/filenameLatency="latency$i.txt" work.NEMU_NetEmulation -do "run 15000ns;"
}
