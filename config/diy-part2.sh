#!/bin/bash

git clone --depth 1 https://github.com/gSpotx2f/luci-app-temp-status feeds/luci/applications/luci-app-temp-status
git clone --depth 1 https://github.com/DustReliant/luci-app-filetransfer package/xiaouex/luci-app-filetransfer
#rm -rf feeds/smpackage/v2ray-geodata
#git clone --depth 1 https://github.com/sbwml/v2ray-geodata feeds/smpackage/v2ray-geodata
./scripts/feeds update -a
./scripts/feeds install -a 
sed -i 's/--set=llvm\.download-ci-llvm=true/--set=llvm.download-ci-llvm=false/' feeds/packages/lang/rust/Makefile


