CONNECTALDIR ?= /mit/6.375/lab2019f/connectal
MIGDIR ?= /mit/6.375/lab2019f/xilinx/vc707/ddr3_v2_0/

S2H_INTERFACES = \
	ConnectalProcRequest:ConnectalWrapper.connectProc\
	ConnectalMemoryInitialization:ConnectalWrapper.initProc
H2S_INTERFACES = \
	ConnectalWrapper:ConnectalProcIndication:host
BSVFILES += \
	connectal/Ifc.bsv
BSVPATH += / \
	src/ \
	src/proclib \
	$(MIGDIR)

CPPFILES += \
	connectal/main.cpp\
	connectal/Platform.cpp




SOFTWARE_SOCKET_NAME=/tmp/connectal$(USER)
export SOFTWARE_SOCKET_NAME

CONNECTALFLAGS += -D $(VPROC) 
CONNECTALFLAGS += --bscflags " -D $(VPROC) -steps-max-intervals 50 +RTS -K256M -RTS"
CONNECTALFLAGS += --bscflags " -u -show-schedule"
CONNECTALFLAGS += -D IMPORT_HOSTIF -D XILINX_SYS_CLK
CONNECTALFLAGS += --mainclockperiod=21

PIN_TYPE = Top_Pins
PIN_TYPE_INCLUDE = Ifc
AUTOTOP = --interface pins:ConnectalWrapper.pins

ifeq ($(BOARD),vc707g2)
CONNECTALFLAGS += --verilog=$(MIGDIR) \
				  --implconstraint $(MIGDIR)/ddr3_v2_0.xdc \
				  --xci $(CONNECTALDIR)/out/$(BOARD)/ddr3_v2_0/ddr3_v2_0.xci

endif

build_bluesim:
	mkdir -p bluesim/obj/
	cp bolib/*.bo bluesim/obj/.
	make -j8 build.bluesim VPROC=$(VPROC)

build_vc707g2:
	mkdir -p vc707g2/obj/
	cp bolib/*.bo vc707g2/obj/.
	make -j8 build.vc707g2 VPROC=$(VPROC)



include $(CONNECTALDIR)/Makefile.connectal


clean:
	rm -rf bluesim

