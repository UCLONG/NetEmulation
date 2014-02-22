### NEMU_NetEmulation

// --------------------------------------------------------------------------------------------------------------------
// IP Block    : NEMU
// Function    : NetEmulation
// Module name : NEMU_NetEmulation
// Description : TopModule
//           
// Uses        : config.sv, fuctions.sv, network.sv, NEMU_PacketSink, NEMU_PacketSource, NEMU_SerialPortWrapper
// Notes       : 

// --------------------------------------------------------------------------------------------------------------------

### NEMU_PacketSink
    
// --------------------------------------------------------------------------------------------------------------------
// IP Block    : NEMU
// Function    : PacketSink
// Module name : NEMU_PacketSink
// Description : PacketSink is instantiated at each network node. It receives arriving packets, reads data carried in
//             : packets (timestamp) to determine their latency and counts the number of sent and received packets
//             : at each core.
// Uses        : config.sv
// Notes       : 

// --------------------------------------------------------------------------------------------------------------------
    
### NEMU_PacketSource

// --------------------------------------------------------------------------------------------------------------------
// IP Block    : NEMU
// Function    : PacketSource
// Module name : NEMU_PacketSource
// Description : PacketSource is instantiated at each core. Creates packets send through the network (packet structure
//             : define in config.sv). Able to create uniform, hotspot and stream traffic patterns.
// Uses        : config.sv, LIB_FIFO, NEMU_RandomNoGen
// Notes       : 
// --------------------------------------------------------------------------------------------------------------------


### NEMU_RandomNoGen 
    
// --------------------------------------------------------------------------------------------------------------------
// IP Block    : NEMU
// Function    : RandomNoGen
// Module name : NEMU_RandomNoGen
// Description : Creates a random number of arbitrary range. Uses shift registers to create pseudo-random numbers.
//             : If required range is of power of two, a pseudo-random number created may be out of range, in which case
//             : value of a counter is assigned as a pseudo-random number.
// Uses        : config.sv
// Notes       : 

// --------------------------------------------------------------------------------------------------------------------

### NEMU_SerialPortOutput

// --------------------------------------------------------------------------------------------------------------------
// IP Block    : NEMU
// Function    : SerialPortOutput
// Module name : NEMU_SerialPortOutput
// Description : Enables data transmission via an RS-232 port
// Uses        : LIB_FIFO
// Notes       : 

// --------------------------------------------------------------------------------------------------------------------


### NEMU_SerialPortWrapper

// --------------------------------------------------------------------------------------------------------------------
// IP Block    : NEMU
// Function    : SerialPortWrapper
// Module name : NEMU_SerialWrapper
// Description : Wrapper used to divide latency and packet count data into 8 bit words, that are then transmitted via
//             : rs-232 port (NEMU_SerialPortOutput)
// Uses        : config.sv, NEMU_SerialPortOutput
// Notes       : 

// --------------------------------------------------------------------------------------------------------------------


### NEMU_FofoPkt

// --------------------------------------------------------------------------------------------------------------------
// IP Block    : NEMU
// Function    : FifoPkt
// Module name : NEMU_FifoPkt
// Description : 
//           
// Uses        : config.sv
// Notes       : 

// --------------------------------------------------------------------------------------------------------------------

