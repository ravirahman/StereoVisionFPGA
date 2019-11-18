
include $(CLEAR_VARS)
DTOP?=/afs/athena.mit.edu/user/m/d/mdecea/6.375/StereoVisionFPGA/connectal/bluesim
CONNECTALDIR?=/afs/athena.mit.edu/course/6/6.375/lab2019f/connectal
LOCAL_ARM_MODE := arm
include $(CONNECTALDIR)/scripts/Makefile.connectal.application
LOCAL_SRC_FILES := /afs/athena.mit.edu/user/m/d/mdecea/6.375/StereoVisionFPGA/connectal/connectal_test.cpp /afs/athena.mit.edu/course/6/6.375/lab2019f/connectal/cpp/dmaManager.c /afs/athena.mit.edu/course/6/6.375/lab2019f/connectal/cpp/platformMemory.cpp /afs/athena.mit.edu/course/6/6.375/lab2019f/connectal/cpp/transportXsim.c $(PORTAL_SRC_FILES)

LOCAL_PATH :=
LOCAL_MODULE := android.exe
LOCAL_MODULE_TAGS := optional
LOCAL_LDLIBS := -llog   
LOCAL_CPPFLAGS := "-march=armv7-a"
LOCAL_CFLAGS := -I$(DTOP)/jni -I$(CONNECTALDIR) -I$(CONNECTALDIR)/cpp -I$(CONNECTALDIR)/lib/cpp   -Werror
LOCAL_CXXFLAGS := -I$(DTOP)/jni -I$(CONNECTALDIR) -I$(CONNECTALDIR)/cpp -I$(CONNECTALDIR)/lib/cpp   -Werror
LOCAL_CFLAGS2 := $(cdefines2)s

include $(BUILD_EXECUTABLE)
