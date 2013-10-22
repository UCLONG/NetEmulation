General Description
For each core in the network a source is instantiated which uses linear feedback shift registers to produce random packet injection times and destinations. Generated packets reside in buffers before injection into the network to allow realistic latency measurements (See Dally and Towles, chapter 24).


Traffic Types
Uncommenting one of the traffic parameter definitions in config.sv sets the traffic type. Currently all packet arrivals are uniform random, except for trace data:

UNIFORM: uniform random packet destinations
HOTSPOT: Hotpot traffic was implemented by using LFSRs and conditional statements to formulate an approximate 30% chance of sending to two central cores.
STREAM: streaming traffic between 2 ports, random for all other ports. The packet generation of a specific source was hardcoded with a destination and the ‘measure’ bit was set only if the packet had the specific source number.
TRACE: packet arrivals and destinations are determined by stored trace files.