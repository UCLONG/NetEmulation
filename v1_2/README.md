# NetEmulationTest / v1_2 /#

Copy taken from collab.ee.ucl.ac.uk on 08/10/2013

## Sub Folders ##

### arbiters ###

>**DESCRIPTION :** Enter Description Here  
**NOTES :** Enter Notes Here

### mesh ###

>**DESCRIPTION :** Enter Description Here  
**NOTES :** Enter Notes Here

### simple_optical ###

>**DESCRIPTION :** Enter Description Here  
**NOTES :** Enter Notes Here
  
### synth ###

>**DESCRIPTION :** Enter Description Here  
**NOTES :** Enter Notes Here

## Files ##

### arbiter.sv ###

>**DESCRIPTION :** Enter Description Here  
**NOTES :** Enter Notes Here

### config.sv ###
 
>**DESCRIPTION :**  defines the top level parameters for FPGA emulation of networks on chip including packet structure.  Includes function.sv.  
**NOTES :**
   
### delay_control.sv ###
 
>**DESCRIPTION :** Enter Description Here  
**NOTES :** Enter Notes Here

### fifo.sv ###

>**DESCRIPTION :**  First In First Out buffer.  
**PROVIDES :**  packet_source.sv  
**NOTES :**  Might not work for buffer sizes that are not a function of 2^n.  Not sure.

### fifo_pkt.sv ###
 
>**DESCRIPTION :** Enter Description Here  
**NOTES :** Enter Notes Here

### functions.sv ###
 
>**DESCRIPTION :** Common functions such as log2.  
**PROVIDES :** config.sv  
**NOTES :** Needs formatting

### net.do ###

>**DESCRIPTION :**  Network emulation simulation script for modelsim.  Instructs the simulator which modules to compile, sets up the wave window and runs the simulation.  
**USES :** optical_wave.do  
**NOTES :**  Requires lines to be commented and uncommented dependent upon which network is to be simulated.

### net_emulation.sv ###

>**DESCRIPTION :**  Top level module.  Designed to be used for both simulation and synthesis, controlled by commenting/uncommenting the parameter `SYNTHESIS in the config file.  
**USES :**  packet_source.sv , packet_sink.sv , network.sv or network.vhdl  
**NOTES :** Synthesis is currently untested.  Appears it has been developed for VHDL also, however some modules do not have a VHDL equivalent, perhaps VHDL should be a branch until complete?

### net_emulation.sv.bak ###

>**DESCRIPTION :** Enter Description Here  
**NOTES :** Enter Notes Here

### network.sv ###

>**DESCRIPTION :** Enter Description Here  
**NOTES :** Enter Notes Here

### network.vhdl ###

>**DESCRIPTION :** Enter Description Here  
**NOTES :** Enter Notes Here

### optical_wave.do ###

>**DESCRIPTION :**  Network emulation simulation script for modelsim.  Sets up the wave window.  
**PROVIDES :** net.do  
**NOTES :**

### packet_sink.sv ###

>**DESCRIPTION :**  A single instance of packet_sink is attached to all the network input and output ports. The sink records the total number of valid packet inputs to and outputs from the network and their latency. Packet errors are also flagged for debug purposes whenever a packet is received at the wrong destination.  
**PROVIDES :**  net_emulation.sv  
**NOTES :**  Different networks will need different measurements. We need a way to deal with this without constantly changing the code. packet_sink.sv can be the generic sink with individual networks having their own sink module if required.

### packet_sink_single_ch.sv ###

>**DESCRIPTION :** Enter Description Here  
**NOTES :** Enter Notes Here
  
### packet_source.sv ###

>**DESCRIPTION :** For each core in the network a packet_source is instantiated which uses linear feedback shift registers to produce random packet injection times and destinations. Generated packets reside in buffers before injection into the network to allow realistic latency measurements.  
**PROVIDES :** net_emulation.sv  
**USES :** fifo.sv  
**NOTES :**

### packet_source_trace.sv ###

>**DESCRIPTION :** Enter Description Here  
**NOTES :** Enter Notes Here

### ppe.sv ###

>**DESCRIPTION :** Enter Description Here  
**NOTES :** Enter Notes Here

### sr_packet.sv ###

>**DESCRIPTION :** Enter Description Here  
**NOTES :** Enter Notes Here
