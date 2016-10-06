LOCAL_PATH:= $(call my-dir)

mini_src_files := \
	VolumeManager.cpp \
	CommandListener.cpp \
	VoldCommand.cpp \
	NetlinkManager.cpp \
	NetlinkHandler.cpp \
	Process.cpp \
	fs/Exfat.cpp \
	fs/Ext4.cpp \
	fs/F2fs.cpp \
	fs/Ntfs.cpp \
	fs/Vfat.cpp \
	Loop.cpp \
	Devmapper.cpp \
	ResponseCode.cpp \
	CheckBattery.cpp \
	VoldUtil.c \
	Disk.cpp \
	DiskPartition.cpp \
	VolumeBase.cpp \
	PublicVolume.cpp \
	PrivateVolume.cpp \
	EmulatedVolume.cpp \
	Utils.cpp \
	MoveTask.cpp \
	Benchmark.cpp \
	TrimTask.cpp \
	ScryptParameters.cpp \
	secontext.cpp \
	main.cpp

full_src_files := \
	$(mini_src_files) \
	Keymaster.cpp \
	CryptCommandListener.cpp \
	Ext4Crypt.cpp \
	ScryptParameters.cpp \
	KeyStorage.cpp

common_c_includes := \
	system/extras/f2fs_utils \
	external/scrypt/lib/crypto \
	frameworks/native/include \
	system/security/keystore \
	external/e2fsprogs/lib

common_libraries := \
	libsysutils \
	libcrypto_utils \
	libhidlbase \
	libbinder \
	libcutils \
	liblog \
	libdiskconfig \
	liblogwrap \
	libf2fs_sparseblock \
	libcrypto_utils \
	libselinux \
	libutils

common_shared_libraries := \
	$(common_libraries) \
	libhardware_legacy \
	libext4_utils \
	libcrypto \
	libhardware \
	libbase \
	libhwbinder \
	android.hardware.keymaster@3.0 \
	libkeystore_binder

common_static_libraries := \
	libbootloader_message \
	libfs_mgr \
	libfec \
	libfec_rs \
	libext4_utils \
	libsparse \
	libsquashfs_utils \
	libscrypt_static \
	libbatteryservice \
	libavb \
	libz

vold_conlyflags := -std=c11
vold_cflags := -Werror -Wall -Wno-missing-field-initializers -Wno-unused-variable -Wno-unused-parameter

ifeq ($(TARGET_KERNEL_HAVE_EXFAT),true)
  vold_cflags += -DCONFIG_KERNEL_HAVE_EXFAT
endif

required_modules :=
ifeq ($(TARGET_USERIMAGES_USE_EXT4), true)
  ifeq ($(TARGET_USES_MKE2FS), true)
    vold_cflags += -DTARGET_USES_MKE2FS
    required_modules += mke2fs
  else
    required_modules += make_ext4fs
  endif
endif

ifeq ($(TARGET_HW_DISK_ENCRYPTION),true)
  TARGET_CRYPTFS_HW_PATH ?= vendor/qcom/opensource/cryptfs_hw
  common_c_includes += $(TARGET_CRYPTFS_HW_PATH)
  common_shared_libraries += libcryptfs_hw
  vold_cflags += -DCONFIG_HW_DISK_ENCRYPTION
endif

ifeq ($(TARGET_KERNEL_HAVE_NTFS),true)
vold_cflags += -DCONFIG_KERNEL_HAVE_NTFS
endif

include $(CLEAR_VARS)

LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_MODULE := libvold
LOCAL_CLANG := true
LOCAL_SRC_FILES := $(full_src_files)
LOCAL_C_INCLUDES := $(common_c_includes)
LOCAL_SHARED_LIBRARIES := $(common_shared_libraries)
LOCAL_STATIC_LIBRARIES := $(common_static_libraries)
LOCAL_MODULE_TAGS := eng tests
LOCAL_CFLAGS := $(vold_cflags)
LOCAL_CONLYFLAGS := $(vold_conlyflags)
LOCAL_REQUIRED_MODULES := $(required_modules)

include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)

LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_MODULE := vold
LOCAL_CLANG := true
LOCAL_SRC_FILES := \
	vold.c

LOCAL_INIT_RC := vold.rc

LOCAL_C_INCLUDES := $(common_c_includes)
LOCAL_CFLAGS := $(vold_cflags)
LOCAL_CONLYFLAGS := $(vold_conlyflags)

LOCAL_SHARED_LIBRARIES := $(common_shared_libraries)
LOCAL_STATIC_LIBRARIES := libvold $(common_static_libraries)
LOCAL_REQUIRED_MODULES := $(required_modules)

include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)

LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_CLANG := true
LOCAL_SRC_FILES := vdc.cpp
LOCAL_MODULE := vdc
LOCAL_SHARED_LIBRARIES := libcutils libbase
LOCAL_CFLAGS := $(vold_cflags)
LOCAL_CONLYFLAGS := $(vold_conlyflags)
LOCAL_INIT_RC := vdc.rc

include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)

LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_CLANG := true
LOCAL_SRC_FILES:= secdiscard.cpp
LOCAL_MODULE:= secdiscard
LOCAL_SHARED_LIBRARIES := libbase
LOCAL_CFLAGS := $(vold_cflags)
LOCAL_CONLYFLAGS := $(vold_conlyflags)

include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_MODULE := libminivold_static
LOCAL_CLANG := true
LOCAL_SRC_FILES := $(mini_src_files)
LOCAL_C_INCLUDES := $(common_c_includes) system/core/fs_mgr/include system/core/logwrapper/include
LOCAL_SHARED_LIBRARIES := $(common_shared_libraries)
LOCAL_STATIC_LIBRARIES := $(common_static_libraries)
LOCAL_MODULE_TAGS := eng tests
LOCAL_CFLAGS := $(vold_cflags) -DMINIVOLD
LOCAL_CONLYFLAGS := $(vold_conlyflags)
include $(BUILD_STATIC_LIBRARY)
