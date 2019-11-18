BASEDIR=$(abspath .)
CONNECTALDIR=/mit/6.375/lab2019f/connectal
DDR3_DIR=$(BASEDIR)/ddr3_6375

# Define HW->SW / SW->HW interfaces
S2H_INTERFACES = MyDutRequest:MyDut.request
H2S_INTERFACES = MyDut:MyDutIndication:host

# bscflags = -keep-fires -aggressive-conditions -Xc++ -D_GLIBCXX_USE_CXX11_ABI=0
# build_dir = ./bscdir

# FILES
BSVFILES = Top_Pins.bsv MyDut.bsv # $(wildcard *.bsv)
CPPFILES = connectal_test.cpp

# add BSV directories other than the current directory (space between entries)
BSVPATH += $(DDR3_DIR):$(BASEDIR)/tests

# Connectal Flags (125 MHz clock)
CONNECTALFLAGS += --mainclockperiod 8 --bscflags " -u --keep-fires -u -show-schedule "
CONNECTALFLAGS += --bscflags " -steps-max-intervals 50 +RTS -K256M -RTS"

# Additional Connectal Flags for DRAM pins & clocks
CONNECTALFLAGS += -D IMPORT_HOSTIF -D XILINX_SYS_CLK
PIN_TYPE = Top_Pins
PIN_TYPE_INCLUDE = Top_Pins
AUTOTOP = --interface pins:MyDut.pins

ifeq ($(BOARD),vc707g2)
# Use Xilinx DRAM IP built for vc707 (not used in simulation)
CONNECTALFLAGS += --verilog=$(DDR3_DIR) \
					--implconstraint $(DDR3_DIR)/ddr3_v2_0.xdc \
					--xci $(CONNECTALDIR)/out/$(BOARD)/ddr3_v2_0/ddr3_v2_0.xci
endif

include $(CONNECTALDIR)/Makefile.connectal

.PHONY: simulation fpga fpgaUpdateSW run_simulation run_fpga program_fpga run_fpgaSW

# compile: $(BSVFILES)
# 	mkdir -p $(build_dir)
# 	bsc -u -sim -simdir $(build_dir) -bdir $(build_dir) -info-dir $(build_dir) $(bscflags) -p +:$(BSVPATH) -g mkTest $<

# link: compile
# 	bsc -e mkTest -sim -o ./out -simdir $(build_dir) -bdir $(build_dir) -info-dir $(build_dir) $(bscflags)

# simulation: link

simulation:
	# rm -rf $(BASEDIR)/bluesim
	$(MAKE) build.bluesim

fpga:
	# rm -rf $(BASEDIR)/vc707g2
	$(MAKE) build.vc707g2

fpgaUpdateSW:
	rm -f $(BASEDIR)/vc707g2/bin/ubuntu.exe $(BASEDIR)/vc707g2/jni/ubuntu.exe
	make -C $(BASEDIR)/vc707g2 ubuntu.exe

run_simulation:
	$(BASEDIR)/bluesim/bin/ubuntu.exe ${ARG1}

run_fpga:
	lockfile -5 -r 3 -l 120 -s 2 /tmplock/fpgalock
	$(BASEDIR)/vc707g2/bin/ubuntu.exe ${ARG1}
	rm -f /tmplock/fpgalock

program_fpga:
	lockfile -5 -r 3 -l 120 -s 2 /tmplock/fpgalock
	fpgajtag $(BASEDIR)/vc707g2/bin/mkTop.bin.gz
	rm -f /tmplock/fpgalock

run_fpgaSW:
	lockfile -5 -r 3 -l 120 -s 2 /tmplock/fpgalock
	NOPROGRAM=1 $(BASEDIR)/vc707g2/bin/ubuntu.exe ${ARG1}
	rm -f /tmplock/fpgalock

clean:
	rm -rf bscdir bluesim vc707g2 out out.so
