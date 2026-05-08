
#!/bin/bash

# 获取第一个参数，默认为 'default'
MODE="${1:-default}"

case "$MODE" in


diy1|-d1|--diy1)
#↓↓↓↓↓↓↓↓↓↓↓↓从这里开始是运行在首次获取feeds前↓↓↓↓↓↓↓↓↓↓↓↓↓


DEVICE="$MY_DEVICE"
# Add feed sources
sed -i '1i src-git smpackage https://github.com/kenzok8/small-package' feeds.conf.default
#sed -i '1i src-git jell https://github.com/kenzok8/jell' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default
#添加TurboACC
curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh --no-sfe

#Add BBR V3
# 配置 Git 用户信息（GitHub Actions 中必需）
git config --global user.name "xiaouex"
git config --global user.email "xiaouex@live.com"
# 添加上游仓库（fork 源）
UPSTREAM_URL="https://github.com/rockdrilla/fork.openwrt.git"
UPSTREAM_REMOTE="upstream-temp"
# 添加临时远程
git remote add "$UPSTREAM_REMOTE" "$UPSTREAM_URL"
# 获取上游提交
git fetch "$UPSTREAM_REMOTE" e2fa1c32f89ec0bfb726ceb96294b6b957b32d67
git fetch "$UPSTREAM_REMOTE" a7ffdcae8e96eb6dece70622de121f97ff55bfab
# Cherry-pick 两个 commit
git cherry-pick e2fa1c32f89ec0bfb726ceb96294b6b957b32d67
git cherry-pick a7ffdcae8e96eb6dece70622de121f97ff55bfab
# 删除临时远程
git remote remove "$UPSTREAM_REMOTE"
#Add BORE Scheduler
git clone -b main https://github.com/firelzrd/bore-scheduler $GITHUB_WORKSPACE/config/files/BORE
cp $GITHUB_WORKSPACE/config/files/BORE/patches/stable/linux-6.18-bore/*.patch target/linux/generic/hack-6.18
cp $GITHUB_WORKSPACE/config/files/BORE/patches/additions/*.patch target/linux/generic/pending-6.18
rm -rf $GITHUB_WORKSPACE/config/files/BORE
echo 'CONFIG_SCHED_BORE=y' >> target/linux/x86/config-6.18
echo 'CONFIG_MIN_BASE_SLICE_NS=2000000' >> target/linux/x86/config-6.18
echo 'CONFIG_SCHED_BORE=y' >> target/linux/mediatek/filogic/config-6.18
echo 'CONFIG_MIN_BASE_SLICE_NS=2000000' >> target/linux/mediatek/filogic/config-6.18
sed -i '/label = "bl2";/,/};/ { /read-only;/d }' target/linux/mediatek/dts/mt7981b-cmcc-rax3000m-nand.dtso
;;
    
#----------------------------------------------------------------------------------------------------------------------------	
	
	
diy2|-d2|--diy2)
#↓↓↓↓↓↓↓↓↓↓↓↓从这里开始是运行在首次获取feeds后↓↓↓↓↓↓↓↓↓↓↓↓↓


#添加我的插件
mkdir -p package/xiaouex
mv -f $GITHUB_WORKSPACE/config/files/ipv6-helper package/xiaouex/ipv6-helper
mv -f $GITHUB_WORKSPACE/config/files/my-script package/xiaouex/my-script
chmod +x $GITHUB_WORKSPACE/config/files/my-script/files/my_script

git clone --depth 1 https://github.com/gSpotx2f/luci-app-temp-status feeds/luci/applications/luci-app-temp-status
git clone --depth 1 https://github.com/DustReliant/luci-app-filetransfer package/xiaouex/luci-app-filetransfer
rm -rf feeds/smpackage/v2ray-geodata
git clone --depth 1 https://github.com/sbwml/v2ray-geodata feeds/smpackage/v2ray-geodata
./scripts/feeds update -a
./scripts/feeds install -a 
sed -i 's/--set=llvm\.download-ci-llvm=true/--set=llvm.download-ci-llvm=false/' feeds/packages/lang/rust/Makefile
;;
    
	
#-----------------------------------------------------------------------------------------------------------------------------	
	
diy3|-d3|--diy3)
#↓↓↓↓↓↓↓↓↓↓↓↓从这里开始是运行在最终开始编译前↓↓↓↓↓↓↓↓↓↓↓↓↓



DEVICE="$MY_DEVICE"
# 修改默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
#修正连接数（by ベ七秒鱼ベ）
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf
if [[ "$DEVICE" == "rax3000m" ]];then
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate
sed -i 's/ImmortalWrt/MineRouter/g' package/base-files/files/bin/config_generate
fi
;;


#-------------------------------------------------------------------------------------------------------------------------------  
  
*)
echo "无命令执行！"
;;
esac


