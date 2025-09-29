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

git cherry-pick adcfa66a066df5e2b32d91742287b13b5a11cff2
