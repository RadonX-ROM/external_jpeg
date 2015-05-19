LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_ARM_MODE := arm

LOCAL_SRC_FILES := \
    jcapimin.c jcapistd.c jccoefct.c jccolor.c jcdctmgr.c jchuff.c \
    jcinit.c jcmainct.c jcmarker.c jcmaster.c jcomapi.c jcparam.c \
    jcphuff.c jcprepct.c jcsample.c jctrans.c jdapimin.c jdapistd.c \
    jdatadst.c jdatasrc.c jdcoefct.c jdcolor.c jddctmgr.c jdhuff.c \
    jdinput.c jdmainct.c jdmarker.c jdmaster.c jdmerge.c jdphuff.c \
    jdpostct.c jdsample.c jdtrans.c jerror.c jfdctflt.c jfdctfst.c \
    jfdctint.c jidctflt.c jidctfst.c jidctint.c jidctred.c jquant1.c \
    jquant2.c jutils.c jmemmgr.c armv6_idct.S

ifeq (,$(TARGET_BUILD_APPS))
# building against master
# use ashmem as libjpeg decoder's backing store
LOCAL_CFLAGS += -DUSE_ANDROID_ASHMEM
LOCAL_SRC_FILES += \
    jmem-ashmem.c
else
# unbundled branch, built against NDK.
LOCAL_SDK_VERSION := 17
# the original android memory manager.
# use sdcard as libjpeg decoder's backing store
LOCAL_SRC_FILES += \
    jmem-android.c
endif

LOCAL_CFLAGS += -DAVOID_TABLES
LOCAL_CFLAGS += -O3 -fstrict-aliasing -fprefetch-loop-arrays
#LOCAL_CFLAGS += -march=armv6j

# enable tile based decode
LOCAL_CFLAGS += -DANDROID_TILE_BASED_DECODE

ifeq ($(TARGET_ARCH),x86)
  LOCAL_CFLAGS += -DANDROID_INTELSSE2_IDCT
  LOCAL_SRC_FILES += jidctintelsse.c
endif

ifneq (, $(filter arm, $(strip $(TARGET_ARCH)) $(strip $(TARGET_2ND_ARCH))))
  ifeq ($(ARCH_ARM_HAVE_NEON),true)
    #use NEON accelerations
    LOCAL_CFLAGS_arm += -DNV_ARM_NEON
    LOCAL_SRC_FILES_arm += \
        jsimd_arm_neon.S \
        jsimd_neon.c
  else
    # enable armv6 idct assembly
    LOCAL_CFLAGS += -DANDROID_ARMV6_IDCT
  endif
endif

# use mips assembler IDCT implementation if MIPS DSP-ASE is present
ifeq ($(strip $(TARGET_ARCH)),mips)
  ifeq ($(strip $(ARCH_MIPS_HAS_DSP)),true)
  LOCAL_CFLAGS += -DANDROID_MIPS_IDCT
  LOCAL_SRC_FILES += \
      mips_jidctfst.c \
      mips_idct_le.S
  endif
endif

LOCAL_MODULE := libjpeg_static

include $(BUILD_STATIC_LIBRARY)

# Build shared library
include $(CLEAR_VARS)

LOCAL_MODULE := libjpeg

LOCAL_MODULE_TAGS := optional

LOCAL_WHOLE_STATIC_LIBRARIES = libjpeg_static

ifeq (,$(TARGET_BUILD_APPS))
LOCAL_SHARED_LIBRARIES := \
    libcutils
else
# unbundled branch, built against NDK.
LOCAL_SDK_VERSION := 17
endif

include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_ARM_MODE := arm
LOCAL_SRC_FILES := \
	cjpeg.c cdjpeg.h jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h cderror.h jversion.h rdswitch.c cdjpeg.c rdtarga.c rdppm.c rdgif.c rdbmp.c
LOCAL_MODULE:= cjpeg
LOCAL_MODULE_TAGS := debug
LOCAL_SHARED_LIBRARIES := libc libcutils libjpeg
LOCAL_MULTILIB := both
LOCAL_MODULE_STEM_64 := $(LOCAL_MODULE)64
LOCAL_MODULE_STEM_32 := $(LOCAL_MODULE)32
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_ARM_MODE := arm
LOCAL_SRC_FILES := \
	djpeg.c cdjpeg.h jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h cderror.h jversion.h cdjpeg.c wrppm.c wrgif.c wrbmp.c rdcolmap.c wrtarga.c
LOCAL_MODULE:= djpeg
LOCAL_MODULE_TAGS := debug
LOCAL_SHARED_LIBRARIES := libc libcutils libjpeg
LOCAL_MULTILIB := both
LOCAL_MODULE_STEM_64 := $(LOCAL_MODULE)64
LOCAL_MODULE_STEM_32 := $(LOCAL_MODULE)32
include $(BUILD_EXECUTABLE)

######################################################
###                  tjbench                       ###
######################################################
include $(CLEAR_VARS)
# From autoconf-generated Makefile
tjbench_SOURCES = tjbench.c bmp.c tjutil.c rdbmp.c rdppm.c \
        wrbmp.c wrppm.c \
        turbojpeg.c transupp.c jdatadst-tj.c jdatasrc-tj.c \

LOCAL_SRC_FILES:= $(tjbench_SOURCES)
LOCAL_SHARED_LIBRARIES := libjpeg
LOCAL_CFLAGS := -DBMP_SUPPORTED -DPPM_SUPPORTED \
         -DANDROID -DANDROID_TILE_BASED_DECODE -DENABLE_ANDROID_NULL_CONVERT
LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLE)
LOCAL_MODULE_TAGS := debug
LOCAL_MODULE := tjbench

LOCAL_MULTILIB := both
LOCAL_MODULE_STEM_64 := $(LOCAL_MODULE)64
LOCAL_MODULE_STEM_32 := $(LOCAL_MODULE)32

include $(BUILD_EXECUTABLE)
