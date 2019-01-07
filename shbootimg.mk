#
# Copyright (C) 2012 The CyanogenMod Project
# Copyright (C) 2013 OmniROM Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

INSTALLED_BOOTIMAGE_TARGET := $(PRODUCT_OUT)/boot.img
INSTALLED_P1LN_BOOTIMAGE_TARGET := $(PRODUCT_OUT)/boot_p1ln.img

INSTALLED_P1LN_KERNEL_TARGET := $(PRODUCT_OUT)/kernel_p1ln

KERNEL_P1LN_OUT := $(TARGET_OUT_INTERMEDIATES)/KERNEL_P1LN_OBJ
KERNEL_P1LN_CONFIG := $(KERNEL_P1LN_OUT)/.config
KERNEL_P1LN_DEFCONFIG := omni_p1ln_defconfig

uncompressed_ramdisk := $(PRODUCT_OUT)/ramdisk.cpio
$(uncompressed_ramdisk): $(INSTALLED_RAMDISK_TARGET)
	zcat $< > $@

$(KERNEL_P1LN_OUT):
	mkdir -p $(KERNEL_P1LN_OUT)

$(KERNEL_P1LN_CONFIG): $(KERNEL_P1LN_OUT)
	$(MAKE) -C $(KERNEL_SRC) O=$(KERNEL_P1LN_OUT) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) $(KERNEL_P1LN_DEFCONFIG)

$(INSTALLED_P1LN_KERNEL_TARGET): $(KERNEL_P1LN_OUT) $(KERNEL_P1LN_CONFIG) $(recovery_uncompressed_ramdisk) $(uncompressed_ramdisk) $(PRODUCT_OUT)/utilities/busybox $(PRODUCT_OUT)/utilities/make_ext4fs
	$(MAKE) -C $(KERNEL_SRC) O=$(KERNEL_P1LN_OUT) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) $(BOARD_KERNEL_IMAGE_NAME)
	$(ACP) -fp $(KERNEL_P1LN_OUT)/arch/$(KERNEL_ARCH)/boot/$(BOARD_KERNEL_IMAGE_NAME) $(INSTALLED_P1LN_KERNEL_TARGET)

TARGET_KERNEL_BINARIES: $(KERNEL_OUT) $(KERNEL_CONFIG) $(KERNEL_HEADERS_INSTALL) $(recovery_uncompressed_ramdisk) $(uncompressed_ramdisk)
	$(MAKE) -C $(KERNEL_SRC) O=$(KERNEL_OUT) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) $(BOARD_KERNEL_IMAGE_NAME)
	-$(MAKE) -C $(KERNEL_SRC) O=$(KERNEL_OUT) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) modules
	-$(MAKE) -C $(KERNEL_SRC) O=$(KERNEL_OUT) INSTALL_MOD_PATH=../../$(KERNEL_MODULES_INSTALL) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) modules_install

$(INSTALLED_BOOTIMAGE_TARGET): $(INSTALLED_KERNEL_TARGET) $(INSTALLED_P1LN_KERNEL_TARGET) $(PRODUCT_OUT)/utilities/busybox $(PRODUCT_OUT)/utilities/erase_image $(PRODUCT_OUT)/utilities/flash_image $(PRODUCT_OUT)/utilities/make_ext4fs
	$(ACP) -fp $< $@
	$(hide) cp $(PRODUCT_OUT)/recovery/root/sbin/mkfs.f2fs $(PRODUCT_OUT)/utilities/mkfs.f2fs
	$(ACP) -fp $(INSTALLED_P1LN_KERNEL_TARGET) $(INSTALLED_P1LN_BOOTIMAGE_TARGET)

$(INSTALLED_RECOVERYIMAGE_TARGET): $(INSTALLED_KERNEL_TARGET)
	$(ACP) -fp $< $@
