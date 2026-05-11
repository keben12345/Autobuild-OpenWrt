#!/bin/bash


DEVICE="$MY_DEVICE"


# Add feed sources
sed -i '1i src-git smpackage https://github.com/kenzok8/small-package' feeds.conf.default
#sed -i '1i src-git jell https://github.com/kenzok8/jell' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default
#curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh --no-sfe

chmod +x $GITHUB_WORKSPACE/config/files/my-script/files/my_script
mkdir -p package/xiaouex
mv -f $GITHUB_WORKSPACE/config/files/ipv6-helper package/xiaouex/ipv6-helper
mv -f $GITHUB_WORKSPACE/config/files/my-script package/xiaouex/my-script

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
