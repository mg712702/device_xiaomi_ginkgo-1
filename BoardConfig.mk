# config.mk
#
# Product-specific compile-time definitions.
#
TARGET_BOARD_PLATFORM := $(TRINKET)
TARGET_SEPOLICY_DIR := trinket
TARGET_BOOTLOADER_BOARD_NAME := $(TRINKET)
TARGET_PERF_DIR := trinket

TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := kryo300

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a73

BOARD_SECCOMP_POLICY := device/qcom/$(TARGET_BOARD_PLATFORM)/seccomp

#Generate DTBO image
BOARD_KERNEL_SEPARATED_DTBO := true

TARGET_NO_BOOTLOADER := false
TARGET_USES_UEFI := true
TARGET_NO_KERNEL := false
BOARD_PRESIL_BUILD := true
-include vendor/qcom/prebuilt/$(TRINKET)/BoardConfigVendor.mk
-include $(QCPATH)/common/$(TRINKET)/BoardConfigVendor.mk

# Some framework code requires this to enable BT
BOARD_HAVE_BLUETOOTH := false
BOARD_USES_WIPOWER := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/qcom/common

USE_OPENGL_RENDERER := true
BOARD_USE_LEGACY_UI := true

#Disable appended dtb
TARGET_KERNEL_APPEND_DTB := false

# Set Header version for bootimage
ifneq ($(strip $(TARGET_KERNEL_APPEND_DTB)),true)
#Enable dtb in boot image and Set Header version
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_BOOTIMG_HEADER_VERSION := 2
else
BOARD_BOOTIMG_HEADER_VERSION := 1
endif

BOARD_MKBOOTIMG_ARGS := --header_version $(BOARD_BOOTIMG_HEADER_VERSION)

ifeq ($(ENABLE_AB), true)
# Defines for enabling A/B builds
AB_OTA_UPDATER := true
# Full A/B partition update set
# AB_OTA_PARTITIONS := xbl rpm tz hyp pmic modem abl boot keymaster cmnlib cmnlib64 system bluetooth

# Minimum partition set for automation to test recovery generation code
# Packages generated by using just the below flag cannot be used for updating a device. You must pass
# in the full set mentioned above as part of your make commandline
AB_OTA_PARTITIONS ?= boot vendor
else
# Non-A/B section. Define cache and recovery partition variables.
BOARD_CACHEIMAGE_PARTITION_SIZE := 268435456
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
ifeq ($(BOARD_AVB_ENABLE), true)
   BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
   BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
   BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
   BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1
endif
# Enable DTBO for recovery image
BOARD_INCLUDE_RECOVERY_DTBO := true
endif

BOARD_USES_METADATA_PARTITION := true

ifeq ($(ENABLE_AB), true)
    ifneq ($(strip $(BOARD_DYNAMIC_PARTITION_ENABLE)),true)
        TARGET_RECOVERY_FSTAB := device/qcom/$(TRINKET)/recovery_AB_variant.fstab
    else
        ifeq ($(SYSTEMEXT_SEPARATE_PARTITION_ENABLE), true)
            TARGET_RECOVERY_FSTAB := device/qcom/$(TRINKET)/recovery_AB_dynamic_partition.fstab
        else
            TARGET_RECOVERY_FSTAB := device/qcom/$(TRINKET)/recovery_AB_dynamic_partition_noSysext.fstab
        endif
    endif
else
    ifneq ($(strip $(BOARD_DYNAMIC_PARTITION_ENABLE)),true)
        TARGET_RECOVERY_FSTAB := device/qcom/$(TRINKET)/recovery_non-AB_variant.fstab
    else
        ifeq ($(SYSTEMEXT_SEPARATE_PARTITION_ENABLE), true)
            TARGET_RECOVERY_FSTAB := device/qcom/$(TRINKET)/recovery_non-AB_dynamic_partition.fstab
        else
            TARGET_RECOVERY_FSTAB := device/qcom/$(TRINKET)/recovery_non-AB_dynamic_partition_noSysext.fstab
        endif
    endif
endif

#Enable compilation of oem-extensions to recovery
#These need to be explicitly
ifneq ($(AB_OTA_UPDATER),true)
    TARGET_RECOVERY_UPDATER_LIBS += librecovery_updater_msm
endif

### Dynamic partition Handling
ifneq ($(strip $(BOARD_DYNAMIC_PARTITION_ENABLE)),true)
BOARD_VENDORIMAGE_PARTITION_SIZE := 1073741824
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 3221225472
BOARD_BUILD_SYSTEM_ROOT_IMAGE := true
    ifeq ($(ENABLE_AB), true)
        TARGET_NO_RECOVERY := true
        BOARD_USES_RECOVERY_AS_BOOT := true
    else
        BOARD_RECOVERYIMAGE_PARTITION_SIZE := 0x04000000
        ifeq ($(BOARD_KERNEL_SEPARATED_DTBO),true)
            # Enable DTBO for recovery image
            BOARD_INCLUDE_RECOVERY_DTBO := true
        endif
    endif
else
# Define the Dynamic Partition sizes and groups.
    ifeq ($(ENABLE_AB), true)
        BOARD_SUPER_PARTITION_SIZE := 12884901888
    else
        BOARD_SUPER_PARTITION_SIZE := 6442450944
    endif
    ifeq ($(BOARD_KERNEL_SEPARATED_DTBO),true)
        # Enable DTBO for recovery image
        BOARD_INCLUDE_RECOVERY_DTBO := true
    endif
BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 6438256640
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := vendor
BOARD_EXT4_SHARE_DUP_BLOCKS := true
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 0x06000000
endif
### Dynamic partition Handling

ifeq ($(SHIPPING_API_LEVEL),29)
BOARD_SYSTEMSDK_VERSIONS:=29
else
BOARD_SYSTEMSDK_VERSIONS:=28
endif

#Enable split vendor image
ENABLE_VENDOR_IMAGE := true
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR := vendor
BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED := true
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_BOOTIMAGE_PARTITION_SIZE := 0x04000000
BOARD_USERDATAIMAGE_PARTITION_SIZE := 10737418240
BOARD_PERSISTIMAGE_PARTITION_SIZE := 33554432
BOARD_DTBOIMG_PARTITION_SIZE := 0x0800000
BOARD_METADATAIMAGE_PARTITION_SIZE := 16777216
BOARD_PERSISTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_FLASH_BLOCK_SIZE := 131072 # (BOARD_KERNEL_PAGESIZE * 64)

TARGET_KERNEL_VERSION := 4.14
BOARD_PREBUILT_DTBOIMAGE := out/target/product/sm6150/prebuilt_dtbo.img
BOARD_VENDOR_KERNEL_MODULES := \
    $(KERNEL_MODULES_OUT)/audio_apr.ko \
    $(KERNEL_MODULES_OUT)/audio_snd_event.ko \
    $(KERNEL_MODULES_OUT)/audio_wglink.ko \
    $(KERNEL_MODULES_OUT)/audio_q6_pdr.ko \
    $(KERNEL_MODULES_OUT)/audio_q6_notifier.ko \
    $(KERNEL_MODULES_OUT)/audio_adsp_loader.ko \
    $(KERNEL_MODULES_OUT)/audio_q6.ko \
    $(KERNEL_MODULES_OUT)/audio_usf.ko \
    $(KERNEL_MODULES_OUT)/audio_pinctrl_wcd.ko \
    $(KERNEL_MODULES_OUT)/audio_swr.ko \
    $(KERNEL_MODULES_OUT)/audio_wcd_core.ko \
    $(KERNEL_MODULES_OUT)/audio_swr_ctrl.ko \
    $(KERNEL_MODULES_OUT)/audio_wsa881x.ko \
    $(KERNEL_MODULES_OUT)/audio_platform.ko \
    $(KERNEL_MODULES_OUT)/audio_hdmi.ko \
    $(KERNEL_MODULES_OUT)/audio_stub.ko \
    $(KERNEL_MODULES_OUT)/audio_wcd9xxx.ko \
    $(KERNEL_MODULES_OUT)/audio_mbhc.ko \
    $(KERNEL_MODULES_OUT)/audio_wcd934x.ko \
    $(KERNEL_MODULES_OUT)/audio_wcd937x.ko \
    $(KERNEL_MODULES_OUT)/audio_wcd937x_slave.ko \
    $(KERNEL_MODULES_OUT)/audio_bolero_cdc.ko \
    $(KERNEL_MODULES_OUT)/audio_wsa_macro.ko \
    $(KERNEL_MODULES_OUT)/audio_va_macro.ko \
    $(KERNEL_MODULES_OUT)/audio_rx_macro.ko \
    $(KERNEL_MODULES_OUT)/audio_tx_macro.ko \
    $(KERNEL_MODULES_OUT)/audio_wcd_spi.ko \
    $(KERNEL_MODULES_OUT)/audio_wcd_cpe.ko \
    $(KERNEL_MODULES_OUT)/audio_cpe_lsm.ko \
    $(KERNEL_MODULES_OUT)/audio_wcd9335.ko \
    $(KERNEL_MODULES_OUT)/audio_native.ko \
    $(KERNEL_MODULES_OUT)/audio_machine_trinket.ko \
    $(KERNEL_MODULES_OUT)/wil6210.ko \
    $(KERNEL_MODULES_OUT)/msm_11ad_proxy.ko \
    $(KERNEL_MODULES_OUT)/rdbg.ko \
    $(KERNEL_MODULES_OUT)/mpq-adapter.ko \
    $(KERNEL_MODULES_OUT)/mpq-dmx-hw-plugin.ko

BOARD_VENDOR_KERNEL_MODULES += $(shell ls $(KERNEL_MODULES_OUT)/*.ko)

TARGET_USES_ION := true
TARGET_USES_NEW_ION_API :=true
TARGET_USES_QCOM_BSP := false
BOARD_KERNEL_CMDLINE := console=ttyMSM0,115200n8 androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 swiotlb=1 earlycon=msm_geni_serial,0x4a90000 loop.max_part=7 cgroup.memory=nokmem,nosocket

BOARD_EGL_CFG := device/qcom/$(TARGET_BOARD_PLATFORM)/egl.cfg

BOARD_KERNEL_BASE        := 0x00000000
BOARD_KERNEL_PAGESIZE    := 4096
BOARD_KERNEL_TAGS_OFFSET := 0x01E00000
BOARD_RAMDISK_OFFSET     := 0x02000000

TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64
TARGET_KERNEL_CROSS_COMPILE_PREFIX := $(shell pwd)/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-androidkernel-
TARGET_USES_UNCOMPRESSED_KERNEL := false

MAX_EGL_CACHE_KEY_SIZE := 12*1024
MAX_EGL_CACHE_SIZE := 2048*1024


BOARD_USES_GENERIC_AUDIO := true
BOARD_QTI_CAMERA_32BIT_ONLY := true
TARGET_NO_RPC := true

TARGET_PLATFORM_DEVICE_BASE := /devices/soc.0/
TARGET_INIT_VENDOR_LIB := libinit_msm

TARGET_COMPILE_WITH_MSM_KERNEL := true

#Enable PD locater/notifier
TARGET_PD_SERVICE_ENABLED := true

#Enable peripheral manager
TARGET_PER_MGR_ENABLED := true

TARGET_HW_DISK_ENCRYPTION := true
TARGET_HW_DISK_ENCRYPTION_PERF := true

# Enable dex pre-opt to speed up initial boot
ifeq ($(HOST_OS),linux)
    ifeq ($(WITH_DEXPREOPT),)
      WITH_DEXPREOPT := true
      WITH_DEXPREOPT_PIC := true
      ifneq ($(TARGET_BUILD_VARIANT),user)
        # Retain classes.dex in APK's for non-user builds
        DEX_PREOPT_DEFAULT := nostripping
      endif
    endif
endif


# Enable sensor multi HAL
USE_SENSOR_MULTI_HAL := true

#Add non-hlos files to ota packages
ADD_RADIO_FILES := true

# Enable QG user space
PMIC_QG_SUPPORT := true

ifeq ($(ENABLE_VENDOR_IMAGE), false)
$(error "Vendor Image is mandatory !!")
endif

#----------------------------------------------------------------------
# wlan specific
#----------------------------------------------------------------------
ifeq ($(strip $(BOARD_HAS_QCOM_WLAN)),true)
include device/qcom/wlan/trinket/BoardConfigWlan.mk
endif

BOARD_VNDK_VERSION:= current
BUILD_BROKEN_PREBUILT_ELF_FILES := true
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_USES_BUILD_HOST_SHARED_LIBRARY := true
BUILD_BROKEN_USES_BUILD_HOST_STATIC_LIBRARY := true
BUILD_BROKEN_USES_BUILD_HOST_EXECUTABLE := true
BUILD_BROKEN_USES_BUILD_COPY_HEADERS := true


BUILD_BROKEN_NINJA_USES_ENV_VARS := SDCLANG_AE_CONFIG SDCLANG_CONFIG SDCLANG_SA_ENABLED SDCLANG_CONFIG_AOSP
BUILD_BROKEN_NINJA_USES_ENV_VARS += TEMPORARY_DISABLE_PATH_RESTRICTIONS
BUILD_BROKEN_NINJA_USES_ENV_VARS += RTIC_MPGEN

#################################################################################
# This is the End of BoardConfig.mk file.
# Now, Pickup other split Board.mk files:
#################################################################################
# TODO: Relocate the system Board.mk files pickup into qssi lunch, once it is up.
-include vendor/qcom/defs/board-defs/system/*.mk
-include vendor/qcom/defs/board-defs/vendor/*.mk
#################################################################################
include device/qcom/sepolicy_vndr/SEPolicy.mk
