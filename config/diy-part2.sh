#!/bin/bash
rm -rf feeds/packages/smpackage/luci-app-smartdns
rm -rf feeds/packages/smpackage/smartdns
git clone --depth 1 https://github.com/gSpotx2f/luci-app-temp-status feeds/luci/applications/luci-app-temp-status
git clone --depth 1 https://github.com/DustReliant/luci-app-filetransfer package/xiaouex/luci-app-filetransfer

git clone --depth 1 https://github.com/pymumu/luci-app-smartdns feeds/packages/smpackage/luci-app-smartdns
git clone --depth 1 https://github.com/pymumu/openwrt-smartdns feeds/packages/smpackage/smartdns
sed -i '/PKG_MIRROR_HASH/d' feeds/packages/smpackage/smartdns/Makefile
sed -i '/PKG_SOURCE_VERSION/d' feeds/packages/smpackage/smartdns/Makefile

./scripts/feeds update -a
./scripts/feeds install -a 
sed -i 's/--set=llvm\.download-ci-llvm=true/--set=llvm.download-ci-llvm=false/' feeds/packages/lang/rust/Makefile

sed -i '87i\
define Host/Patch\
	$(if $(HOST_QUILT),rm -rf $(HOST_BUILD_DIR)/patches; mkdir -p $(HOST_BUILD_DIR)/patches)\
	$(if $(HOST_QUILT),$(call PatchDir/Quilt,$(HOST_BUILD_DIR),$(HOST_PATCH_DIR),))\
	$(if $(HOST_QUILT),touch $(HOST_BUILD_DIR)/.quilt_used)\
	$(if $(HOST_QUILT),,$(if $(wildcard $(HOST_PATCH_DIR)/*.patch), \
		$(foreach p,$(sort $(wildcard $(HOST_PATCH_DIR)/*.patch)), \
			echo "Applying patch $(notdir $p)" ; \
			$(PATCH) -f -p1 -d $(HOST_BUILD_DIR) < $p || \
			{ echo "Patch failed! Please fix: $(notdir $p)!" ; exit 1 ; } ; \
		) \
	))\
endef' package/lang/rust/Makefile
