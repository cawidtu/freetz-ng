SQUASHFS4_HOST_LE_VERSION:=4.3
SQUASHFS4_HOST_LE_SOURCE:=squashfs$(SQUASHFS4_HOST_LE_VERSION).tar.gz
SQUASHFS4_HOST_LE_SOURCE_MD5:=d92ab59aabf5173f2a59089531e30dbf
SQUASHFS4_HOST_LE_SITE:=@SF/squashfs

# Enable legacy SquashFS formats support (SquashFS-1/2/3, ZLIB/LZMA1 compressed)
# 1 - to enable
# 0 - to disable
SQUASHFS4_HOST_LE_ENABLE_LEGACY_FORMATS_SUPPORT:=1

SQUASHFS4_HOST_LE_MAKE_DIR:=$(TOOLS_DIR)/make/squashfs4-host-le
SQUASHFS4_HOST_LE_DIR:=$(TOOLS_SOURCE_DIR)/squashfs4-host-le-$(SQUASHFS4_HOST_LE_VERSION)
SQUASHFS4_HOST_LE_BUILD_DIR:=$(SQUASHFS4_HOST_LE_DIR)/squashfs-tools

SQUASHFS4_HOST_LE_TOOLS:=mksquashfs unsquashfs
SQUASHFS4_HOST_LE_TOOLS_BUILD_DIR:=$(addprefix $(SQUASHFS4_HOST_LE_BUILD_DIR)/,$(SQUASHFS4_HOST_LE_TOOLS))
SQUASHFS4_HOST_LE_TOOLS_TARGET_DIR:=$(SQUASHFS4_HOST_LE_TOOLS:%=$(TOOLS_DIR)/%4-avm-le)

squashfs4-host-le-source: $(DL_DIR)/$(SQUASHFS4_HOST_LE_SOURCE)
ifneq ($(strip $(DL_DIR)/$(SQUASHFS4_HOST_LE_SOURCE)),$(strip $(DL_DIR)/$(SQUASHFS4_HOST_BE_SOURCE)))
$(DL_DIR)/$(SQUASHFS4_HOST_LE_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(SQUASHFS4_HOST_LE_SOURCE) $(SQUASHFS4_HOST_LE_SITE) $(SQUASHFS4_HOST_LE_SOURCE_MD5)
endif

squashfs4-host-le-unpacked: $(SQUASHFS4_HOST_LE_DIR)/.unpacked
$(SQUASHFS4_HOST_LE_DIR)/.unpacked: $(DL_DIR)/$(SQUASHFS4_HOST_LE_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	mkdir -p $(SQUASHFS4_HOST_LE_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(SQUASHFS4_HOST_LE_SOURCE),$(SQUASHFS4_HOST_LE_DIR),1)
	$(call APPLY_PATCHES,$(SQUASHFS4_HOST_LE_MAKE_DIR)/patches,$(SQUASHFS4_HOST_LE_DIR))
	touch $@

$(SQUASHFS4_HOST_LE_TOOLS_BUILD_DIR): $(SQUASHFS4_HOST_LE_DIR)/.unpacked $(LZMA2_HOST_DIR)/liblzma.a
	$(MAKE) -C $(SQUASHFS4_HOST_LE_BUILD_DIR) \
		CC="$(TOOLS_CC)" \
		EXTRA_CFLAGS="-fcommon -DTARGET_FORMAT=AVM_LE -DAVM_FORMAT_AS_OPTION" \
		LEGACY_FORMATS_SUPPORT=$(SQUASHFS4_HOST_LE_ENABLE_LEGACY_FORMATS_SUPPORT) \
		GZIP_SUPPORT=$(SQUASHFS4_HOST_LE_ENABLE_LEGACY_FORMATS_SUPPORT) \
		LZMA_XZ_SUPPORT=$(SQUASHFS4_HOST_LE_ENABLE_LEGACY_FORMATS_SUPPORT) \
		XZ_SUPPORT=1 \
		XZ_DIR="$(abspath $(LZMA2_HOST_DIR))" \
		COMP_DEFAULT=xz \
		XATTR_SUPPORT=0 \
		XATTR_DEFAULT=0 \
		$(SQUASHFS4_HOST_LE_TOOLS)
	touch -c $@

$(SQUASHFS4_HOST_LE_TOOLS_TARGET_DIR): $(TOOLS_DIR)/%4-avm-le: $(SQUASHFS4_HOST_LE_BUILD_DIR)/%
	$(INSTALL_FILE)
	strip $@

squashfs4-host-le: $(SQUASHFS4_HOST_LE_TOOLS_TARGET_DIR)

squashfs4-host-le-clean:
	-$(MAKE) -C $(SQUASHFS4_HOST_LE_BUILD_DIR) clean

squashfs4-host-le-dirclean:
	$(RM) -r $(SQUASHFS4_HOST_LE_DIR)

squashfs4-host-le-distclean: squashfs4-host-le-dirclean
	$(RM) $(SQUASHFS4_HOST_LE_TOOLS_TARGET_DIR)
