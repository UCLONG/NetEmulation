coregen_objects := $(patsubst ./coregen/%.xco,../../build/synth/coregen/%.v,$(wildcard ./coregen/*.xco))

.PHONY : synth coregen clean

synth: coregen
	xflow -wd ../../build/synth -p xc5vlx155t-3ff1136 -synth ../../scripts/c2c-synth.opt -implement ../../scripts/c2c-imp.opt -config bitgen.opt b2bTop.v

coregen : $(coregen_objects)
	
../../build/synth/coregen/%.v : ./coregen/%.xco
	cd ../../build/synth/coregen && coregen -b ../../../src/verilog/coregen/$(notdir $<)
	
clean:
	rm -rf ../../build/synth/xlnx_auto_0_xdb/
	rm -rf ../../build/synth/xst/
	find ../../build/synth/ -maxdepth 1 -type f -exec rm -rf {} \;
	rm -rf ../../build/synth/coregen/cs_icon_xdb/
	rm -rf ../../build/synth/coregen/cs_ila_xdb/
	rm -rf ../../build/synth/coregen/cs_vio_xdb/
	rm -rf ../../build/synth/coregen/tmp/
	rm -rf ../../build/synth/coregen/_xmsgs
	rm -rf ../../scripts/work/
	find ../../build/synth/coregen/ -maxdepth 1 -type f -exec rm -rf {} \;
	
