

##    run: run the program
##         pass parameters to software via 'make RUN_ARGS= run'
RUN_ARGS?=

export DTOP=/afs/athena.mit.edu/user/m/d/mdecea/6.375/StereoVisionFPGA/connectal/bluesim
CONNECTALDIR=/afs/athena.mit.edu/course/6/6.375/lab2019f/connectal
BSVPATH = /afs/athena.mit.edu/user/m/d/mdecea/6.375/StereoVisionFPGA/connectal:/afs/athena.mit.edu/course/6/6.375/lab2019f/connectal/bsv:/afs/athena.mit.edu/user/m/d/mdecea/6.375/StereoVisionFPGA/connectal/bluesim/generatedbsv:/afs/athena.mit.edu/user/m/d/mdecea/6.375/StereoVisionFPGA/connectal/ddr_example/ddr3_6375:/afs/athena.mit.edu/user/m/d/mdecea/6.375/StereoVisionFPGA/bluespec:/afs/athena.mit.edu/course/6/6.375/lab2019f/connectal/lib/bsv:/afs/athena.mit.edu/course/6/6.375/lab2019f/connectal/generated/xilinx:/afs/athena.mit.edu/course/6/6.375/lab2019f/connectal/generated/altera

BOARD=bluesim
PROJECTDIR=/afs/athena.mit.edu/user/m/d/mdecea/6.375/StereoVisionFPGA/connectal/bluesim
MKTOP=mkXsimTop
OS=ubuntu
TOOLCHAIN?=
DUT=mkxsimtop

export INTERFACES = MemServerRequest MMURequest MemServerIndication MMUIndication XsimMsgRequest XsimMsgIndication MyDutRequest MyDutIndication
BSVFILES = /afs/athena.mit.edu/user/m/d/mdecea/6.375/StereoVisionFPGA/connectal/Top_Pins.bsv /afs/athena.mit.edu/user/m/d/mdecea/6.375/StereoVisionFPGA/connectal/MyDut.bsv /afs/athena.mit.edu/course/6/6.375/lab2019f/connectal/bsv/ConnectalMemory.bsv /afs/athena.mit.edu/course/6/6.375/lab2019f/connectal/bsv/XsimIF.bsv /afs/athena.mit.edu/user/m/d/mdecea/6.375/StereoVisionFPGA/connectal/bluesim/generatedbsv/IfcNames.bsv /afs/athena.mit.edu/course/6/6.375/lab2019f/connectal/bsv/DisplayInd.bsv
XCIFILES = 

BSCFLAGS_PROJECT =  -u --keep-fires -u -show-schedule   -steps-max-intervals 50 +RTS -K256M -RTS
SIM_CXX_PROJECT = 
CFLAGS_PROJECT = 
CXXFLAGS_PROJECT = 
XELABFLAGS = 
XSIMFLAGS  = -R
TOPBSVFILE = /afs/athena.mit.edu/course/6/6.375/lab2019f/connectal/bsv/XsimTop.bsv
BSVDEFINES =  -D IMPORT_HOSTIF -D XILINX_SYS_CLK -D ConnectalVersion=18.12.1 -D NumberOfMasters=1 -D PinType=Top_Pins -D PinTypeInclude=Top_Pins -D NumberOfUserTiles=1 -D SlaveDataBusWidth=32 -D SlaveControlAddrWidth=5 -D BurstLenSize=10 -D project_dir=$(DTOP) -D MainClockPeriod=8 -D DerivedClockPeriod=10.000000 -D CnocTop -D XsimHostInterface -D PhysAddrWidth=40 -D SIMULATION -D CONNECTAL_BITS_DEPENDENCES=bsim -D BOARD_bluesim
QTUSED = 
export BSVDEFINES_LIST = IMPORT_HOSTIF XILINX_SYS_CLK ConnectalVersion=18.12.1 NumberOfMasters=1 PinType=Top_Pins PinTypeInclude=Top_Pins NumberOfUserTiles=1 SlaveDataBusWidth=32 SlaveControlAddrWidth=5 BurstLenSize=10 project_dir=$(DTOP) MainClockPeriod=8 DerivedClockPeriod=10.000000 CnocTop XsimHostInterface PhysAddrWidth=40 SIMULATION CONNECTAL_BITS_DEPENDENCES=bsim BOARD_bluesim
export DUT_NAME = mkXsimTop





IMPORT_HOSTIF=IMPORT_HOSTIF
XILINX_SYS_CLK=XILINX_SYS_CLK
ConnectalVersion=18.12.1
NumberOfMasters=1
PinType=Top_Pins
PinTypeInclude=Top_Pins
NumberOfUserTiles=1
SlaveDataBusWidth=32
SlaveControlAddrWidth=5
BurstLenSize=10
project_dir=$(DTOP)
MainClockPeriod=8
DerivedClockPeriod=10.000000
CnocTop=CnocTop
XsimHostInterface=XsimHostInterface
PhysAddrWidth=40
SIMULATION=SIMULATION
CONNECTAL_BITS_DEPENDENCES=bsim
BOARD_bluesim=BOARD_bluesim


include $(CONNECTALDIR)/scripts/Makefile.connectal.build


export VERILOG_PATH=verilog /afs/athena.mit.edu/course/6/6.375/lab2019f/connectal/verilog $(BLUESPEC_VERILOG)
MODELSIM_FILES= 
FPGAMAKE=$(CONNECTALDIR)/../fpgamake/fpgamake
fpgamake.mk: $(VFILE) Makefile prepare_bin_target
	$(Q)if [ -f ../synth-ip.tcl ]; then vivado -mode batch -source ../synth-ip.tcl; fi
	$(Q)$(FPGAMAKE) $(FPGAMAKE_VERBOSE) -o fpgamake.mk --board=bluesim --part=xc7z020clg484-1  --floorplan=      -t $(MKTOP)   -b hw/mkTop.bit   $(VERILOG_PATH)

synth.%:fpgamake.mk
	$(MAKE) -f fpgamake.mk Synth/$*/$*-synth.dcp

hw/mkTop.bit: prepare_bin_target  fpgamake.mk
	$(Q)mkdir -p hw
	$(Q)$(MAKE) -f fpgamake.mk
ifneq ($(XILINX),)
	$(Q)rsync -rav --include="*/" --include="*.rpt" --exclude="*" Impl/ bin
else ifneq ($(ALTERA),)
	$(Q)cp -f $(MKTOP).sof bin
endif




