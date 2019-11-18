
CONNECTALDIR?=/afs/athena.mit.edu/course/6/6.375/lab2019f/connectal
DTOP?=/afs/athena.mit.edu/user/m/d/mdecea/6.375/StereoVisionFPGA/connectal/connectal_ddr/bluesim

TOOLCHAIN?=
ifneq ($(TOOLCHAIN),)
CC=$(TOOLCHAIN)gcc
CXX=$(TOOLCHAIN)g++
endif
CFLAGS_COMMON = -O -g -I$(DTOP)/jni -I$(CONNECTALDIR) -I$(CONNECTALDIR)/cpp -I$(CONNECTALDIR)/lib/cpp   -Wall -Werror -I$(DTOP)/jni -I$(CONNECTALDIR) -I$(CONNECTALDIR)/cpp -I$(CONNECTALDIR)/lib/cpp  
CFLAGS = $(CFLAGS_COMMON)
CFLAGS2 = 

include $(DTOP)/Makefile.autotop
include $(CONNECTALDIR)/scripts/Makefile.connectal.application
SOURCES = /afs/athena.mit.edu/user/m/d/mdecea/6.375/StereoVisionFPGA/connectal/connectal_ddr/connectal_test.cpp /afs/athena.mit.edu/course/6/6.375/lab2019f/connectal/cpp/dmaManager.c /afs/athena.mit.edu/course/6/6.375/lab2019f/connectal/cpp/platformMemory.cpp /afs/athena.mit.edu/course/6/6.375/lab2019f/connectal/cpp/transportXsim.c $(PORTAL_SRC_FILES)
SOURCES2 =  $(PORTAL_SRC_FILES)
XSOURCES = $(CONNECTALDIR)/cpp/XsimTop.cpp $(PORTAL_SRC_FILES)
LDLIBS :=    -lpthread

ubuntu.exe: $(SOURCES)
	$(Q)$(CXX) $(CFLAGS) -o ubuntu.exe $(SOURCES) $(LDLIBS)
	$(Q)[ ! -f ../bin/mkTop.bin.gz ] || $(TOOLCHAIN)objcopy --add-section fpgadata=../bin/mkTop.bin.gz ubuntu.exe

connectal.so: $(SOURCES)
	$(Q)$(CXX) -shared -fpic $(CFLAGS) -o connectal.so $(SOURCES) $(LDLIBS)

ubuntu.exe2: $(SOURCES2)
	$(Q)$(CXX) $(CFLAGS) $(CFLAGS2) -o ubuntu.exe2 $(SOURCES2) $(LDLIBS)

xsim: $(XSOURCES)
	$(CXX) $(CFLAGS) -o xsim $(XSOURCES)
