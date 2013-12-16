.SUFFIXES: .v .xco .bsv .ngc $(SUFFIXES)

# relative location of MIPS64 module 
MIPS64 = ../../processors/mips64
# location of coregen .xco files 
COREGENSRC = ../src/coregen
# location of build directory
BUILD  = ../build

# This environment variable tells the MIPS where to find the software hex files
export C3DTOP=yes

.PHONY : build clean

# Build the coregen cores 
%.v:
	cd $(BUILD)/coregen && coregen -b ../../src/coregen/$(*F).xco	
	
build: $(BUILD)/coregen/icon.v $(BUILD)/coregen/ila.v $(BUILD)/coregen/vio.v 
	cd $(MIPS64)/src/bluespec && make verilog
	cd $(MIPS64)/src/verilog && make coregen
	xflow -wd $(BUILD) -p xc5vlx155t-2ff1136 -synth ../scripts/c3d-synth.opt -implement ../scripts/c3d-imp.opt -config bitgen.opt ../src/c3dTop

# Clean everything except for coregen cores (those take a long time to build)
clean:
	#cd $(BUILD) && rm -rf `dir * | grep -v coregen`

# Clean everything
cleanall:
	cd $(BUILD)/coregen && rm -rf *
	cd $(MIPS64)/src/bluespec && $(MAKE) clean
	cd $(MIPS64)/src/verilog && $(MAKE) clean
