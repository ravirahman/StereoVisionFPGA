BASEDIR=$(abspath .)
CONNECTALDIR=/mit/6.375/lab2019f/connectal
DDR3_DIR=../bluespec/ddr3_6375
BLUESPEC_DIR=$(CONNECTALDIR)/tests/spi/:../bluespec:$(DDR3_DIR):$(CONNECTALDIR)/bsv

# Define HW->SW / SW->HW interfaces
S2H_INTERFACES = MyDutRequest:MyDut.request
H2S_INTERFACES = MyDut:MyDutIndication:host

# FILES
BSVFILES = Top_Pins.bsv MyDut.bsv ../bluespec/Types.bsv

ifeq ($(ROS), 1)
	CPPFILES = ros_connectal.cpp
else
	CPPFILES = connectal_test.cpp
endif

# add BSV directories other than the current directory (space between entries)
BSVPATH += $(DDR3_DIR) ../bluespec

# Connectal Flags (1.25 MHz clock)
CONNECTALFLAGS += -I ../easyBMP/ 
CONNECTALFLAGS += --mainclockperiod 21 --bscflags " -u --keep-fires -u -show-schedule "
CONNECTALFLAGS += --bscflags " -steps-max-intervals 50 +RTS -K256M -RTS"
CONNECTALFLAGS += --cflags=-Wno-error
#CONNECTALFLAGS += --clib " ../easyBMP/ "

ROSFLAGS = -I/opt/ros/kinetic/include/ -I./ -L/opt/ros/kinetic/lib/ -lroscpp -lroslib -lrosconsole -lroscpp_serialization -lxmlrpcpp \
	-lrostime -lcpp_common -lboost_system -lrosconsole_log4cxx -lrosconsole_backend_interface -lmessage_filters

# Additional Connectal Flags for DRAM pins & clocks
CONNECTALFLAGS += -D IMPORT_HOSTIF -D XILINX_SYS_CLK $(ROSFLAGS)
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

.PHONY: simulation fpga fpgaUpdateSW run_simulation run_fpga program_fpga run_fpgaSW compile_bluespec clean ros_listener

ros_listener: ros_listener.cpp
	g++ -std=c++11 -g -o ros ros_listener.cpp $(ROSFLAGS)

simulation:
	rm -rf $(BASEDIR)/bluesim
	$(MAKE) build.bluesim

fpga:
	rm -rf $(BASEDIR)/vc707g2
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

compile_bluespec:
	bsc -u -sim -simdir bscdir -bdir bscdir -info-dir bscdir -keep-fires -aggressive-conditions -Xc++ -D_GLIBCXX_USE_CXX11_ABI=0 -p +:$(BLUESPEC_DIR) -g mkMyDut MyDut.bsv	

clean:
	rm -rf $(BASEDIR)/bluesim
