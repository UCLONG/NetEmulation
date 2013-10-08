create_clock -name "clk" -period 1.5 -waveform {0 0.75} {clk}
set_dont_touch_network clk

set_dont_touch_network reset
set_ideal_network reset
