NDK_ROOT=/home/pfalcon/devel/android-ndk-r5b
#AOSP_ROOT=/home/pfalcon/projects-3rdparty/android-donut
AOSP_ROOT=/home/pfalcon/projects-3rdparty/android-gingerbread
AOSP_HEADERS=android-platform-headers/android-2.3.5_r1
CROSS_COMPILE=arm-linux-androideabi-
API_LEVEL=9
ARCH=arm

CC=$(CROSS_COMPILE)gcc
CXX=$(CROSS_COMPILE)g++
LD=$(CROSS_COMPILE)ld
PLATFORM_PATH=$(NDK_ROOT)/platforms/android-$(API_LEVEL)/arch-$(ARCH)
LDLIBS_PATH_SDK=$(PLATFORM_PATH)/usr/lib
LDLIBS_PATH=lib-nooktablet/
CPPFLAGS = \
    -I$(PLATFORM_PATH)/usr/include \
    -I$(NDK_ROOT)/sources/cxx-stl/system/include \
    -I$(AOSP_HEADERS)/system/core/include \
    -I$(AOSP_HEADERS)/frameworks/base/include \
    -I$(AOSP_HEADERS)/frameworks/base/native/include \
    -I$(AOSP_ROOT)/hardware/libhardware/include \
    -I$(AOSP_ROOT)/external/skia/include \
    -I.
CXXFLAGS=-fno-exceptions

%: %.o
	$(LD) --entry=_start --dynamic-linker /system/bin/linker \
	-nostdlib \
	-rpath /system/lib -rpath-link $(LDLIBS_PATH) -rpath-link $(LDLIBS_PATH_SDK) \
	-L$(LDLIBS_PATH) -L$(LDLIBS_PATH_SDK) \
	$^ $(EXTRA_LIBS) -lstdc++ -lc $(LDLIBS_PATH_SDK)/crtbegin_dynamic.o $(LDLIBS_PATH_SDK)/crtend_android.o -o $@

#-lGLESv2 -lGLESv1_CM -lEGL -lui


ALL = hello hellocpp \
     dlopen ashmem \
     hal-info hal-gralloc hal-copybit \
     display-info gralloc surface-client

all: $(ALL)

hello.o: hello.c
hellocpp.o: hellocpp.cpp

hello: hello.o
hellocpp: hellocpp.o

ashmem: EXTRA_LIBS=-lcutils
ashmem.o: ashmem.c

resize: EXTRA_LIBS=-lsurfaceflinger_client
resize.o: resize.cpp

display-info: EXTRA_LIBS=-lsurfaceflinger_client
display-info.o: display-info.cpp

surface-client: EXTRA_LIBS=-lsurfaceflinger_client
surface-client.o: surface-client.cpp

hal-info: EXTRA_LIBS=-lhardware
hal-info.o: hal-info.c

hal-gralloc: EXTRA_LIBS=-lhardware
hal-gralloc.o: hal-gralloc.c

hal-copybit: EXTRA_LIBS=-lhardware
hal-copybit.o: hal-copybit.c

gralloc: EXTRA_LIBS=-lsurfaceflinger -lsurfaceflinger_client
gralloc.o: gralloc.cpp

gles: EXTRA_LIBS=-lGLESv1_CM -lui
gles.o: gles.c

gles-info: EXTRA_LIBS=-lGLESv1_CM -lui
gles-info.o: gles-info.c

dlopen: EXTRA_LIBS=-ldl

push:
	for exe in $(ALL); do \
	    adb push $$exe /data/local; \
	done

push-%: %
	adb push $^ /data/local

run-%: %
	adb shell /data/local/$^

clean:
	rm -f *.o
