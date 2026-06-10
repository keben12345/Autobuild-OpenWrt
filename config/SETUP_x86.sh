#!/usr/bin/env bash

# ==============================================================================
# GitHub Actions Bash 脚本模板
# ==============================================================================
# 开启严格模式：
# -e: 任何命令执行失败（返回非0）立即退出脚本
# -u: 使用未声明的变量时报错并退出
# -o pipefail: 管道命令中任何一个子命令失败，整个管道被视为失败
set -euo pipefail

# ==========================================
# 全局变量与环境配置
# ==========================================
# 您可以从 GitHub Actions 传入环境变量，或者在此处定义全局变量
WORK_DIR="/workdir"
REPO_DIR="$WORK_DIR/openwrt"
readonly REPO_URL="https://github.com/immortalwrt/immortalwrt"
readonly REPO_BRANCH="openwrt-25.12"
# ==========================================
# 分函数定义 (Sub-functions)
# ==========================================

# 分函数 1：初始化工作环境
function task_step_1() {

    echo "正在执行 [步骤 1]: 初始化工作环境,克隆源码..."
    echo "=== 检查磁盘空间 ==="
    df -hT "$WORK_DIR"

    echo "=== 克隆源码 ==="
    git clone "$REPO_URL" -b "$REPO_BRANCH" "$REPO_DIR"

    echo "=== 创建软链接 ==="
    ln -sf "$REPO_DIR" "$GITHUB_WORKSPACE/openwrt"

    echo "✔ [步骤 1] 初始化工作环境，克隆源码 执行完毕。"
}

# 分函数 2：添加feeds源
function task_step_2() {

    echo "正在执行 [步骤 2]: 添加feeds源..."
    cd $GITHUB_WORKSPACE/openwrt

    sed -i '1i src-git smpackage https://github.com/kenzok8/small-package' feeds.conf.default
    #sed -i '1i src-git jell https://github.com/kenzok8/jell' feeds.conf.default
    sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default
    curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh --no-sfe
    ./scripts/feeds update -a
    echo "✔ [步骤 2] 添加feeds源 执行完毕。"
}

# 分函数 3：添加额外软件包，并执行 feeds install和feeds install
function task_step_3() {

    echo "正在执行 [步骤 3]: 添加额外软件包，并执行 feeds install和feeds install..."
    cd $GITHUB_WORKSPACE/openwrt
    git clone --depth 1 https://github.com/gSpotx2f/luci-app-temp-status feeds/luci/applications/luci-app-temp-status
    #git clone --depth 1 https://github.com/DustReliant/luci-app-filetransfer package/xiaouex/luci-app-filetransfer
    #rm -rf feeds/smpackage/v2ray-geodata
    #git clone --depth 1 https://github.com/sbwml/v2ray-geodata feeds/smpackage/v2ray-geodata
    ./scripts/feeds update -a
    ./scripts/feeds install -a 
    
    echo "✔ [步骤 3] 添加额外软件包，并执行 feeds install和feeds install 执行完毕。"
}

# 分函数 4：添加mihomo smart内核
function task_step_4() {
    echo "正在执行 [步骤 4]: 添加mihomo smart内核..."
    cd $GITHUB_WORKSPACE
    git clone -b core https://github.com/vernesong/OpenClash clash-core

    cd $GITHUB_WORKSPACE
    echo -e "预置Clash内核"
    mkdir -p $GITHUB_WORKSPACE/openwrt/feeds/smpackage/luci-app-openclash/root/etc/openclash/core
    core_path="$GITHUB_WORKSPACE/openwrt/feeds/smpackage/luci-app-openclash/root/etc/openclash/core"
    geo_path="$GITHUB_WORKSPACE/openwrt/feeds/smpackage/luci-app-openclash/root/etc/openclash"

    cd $GITHUB_WORKSPACE/clash-core/dev/smart
    tar -xzf clash-linux-amd64.tar.gz -O > "$core_path/clash_meta"
    wget -qO- https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat > $geo_path/GeoIP.dat
    wget -qO- https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat > $geo_path/GeoSite.dat
    chmod +x $core_path/clash*
    
    echo "✔ [步骤 4]添加mihomo smart内核 执行完毕。"
}

# 分函数 5：合入自定义补丁
function task_step_5() {
    echo "正在执行 [步骤 5]: 合入自定义补丁..."
    cd $GITHUB_WORKSPACE/openwrt
    #Add BBR V3

    # 配置 Git 用户信息（GitHub Actions 中必需）
    git config --global user.name "xiaouex"
    git config --global user.email "xiaouex@live.com"
    # 添加上游仓库（fork 源）
    UPSTREAM_URL_1="https://github.com/nasbdh9/openwrt"
    UPSTREAM_URL_2="https://github.com/devnakx/turboacc"
    UPSTREAM_REMOTE1="upstream-temp1"
    UPSTREAM_REMOTE2="upstream-temp2"
    # 添加临时远程
    git remote add "$UPSTREAM_REMOTE1" "$UPSTREAM_URL_1"
    git remote add "$UPSTREAM_REMOTE2" "$UPSTREAM_URL_2"
    # 获取上游提交
    git fetch "$UPSTREAM_REMOTE1" 94d8192c17b99ff5bc3975c00e2ed7079f6e5b89  #添加BBR3
    git fetch "$UPSTREAM_REMOTE2" b2e8ef848a68ad51e234e17040ff82a21629fa0f  #临时修复turboacc编译
    # Cherry-pick 两个 commit
    git cherry-pick 94d8192c17b99ff5bc3975c00e2ed7079f6e5b89
    git cherry-pick b2e8ef848a68ad51e234e17040ff82a21629fa0f
    # 删除临时远程
    git remote remove "$UPSTREAM_REMOTE1"
    git remote remove "$UPSTREAM_REMOTE2"
    #Add BORE Scheduler
    git clone -b main https://github.com/firelzrd/bore-scheduler $GITHUB_WORKSPACE/config/files/BORE
    cp $GITHUB_WORKSPACE/config/files/BORE/patches/stable/linux-6.12-bore/*.patch target/linux/generic/hack-6.12
    cp $GITHUB_WORKSPACE/config/files/BORE/patches/additions/*.patch target/linux/generic/pending-6.12
    rm -rf $GITHUB_WORKSPACE/config/files/BORE
    
    echo "✔ [步骤 5] 合入自定义补丁 执行完毕。"
}

#分函数 6：编译前最终配置调整
function task_step_6() {
    echo "正在执行 [步骤 6]: 编译前最终配置调整..."
    sed -i 's/--set=llvm\.download-ci-llvm=true/--set=llvm.download-ci-llvm=false/' feeds/packages/lang/rust/Makefile
    cd $GITHUB_WORKSPACE
    mv config/x86/.config openwrt/.config
    cd $GITHUB_WORKSPACE/openwrt
    #修改默认主题
    sed -i 's/luci-theme-bootstrap/luci-theme-material3/g' feeds/luci/modules/luci-base/root/etc/config/luci
    #修正连接数（by ベ七秒鱼ベ）
    sed -i '/will not survive a reimage/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf

    echo 'CONFIG_SCHED_BORE=y' >> target/linux/x86/config-6.12
    echo 'CONFIG_MIN_BASE_SLICE_NS=2000000' >> target/linux/x86/config-6.12
    echo 'CONFIG_SCHED_HRTICK=y' >> target/linux/x86/config-6.12
    echo 'CONFIG_SCHED_AUTOGROUP=y' >> target/linux/x86/config-6.12
    echo 'CONFIG_PREEMPT_VOLUNTARY=y' >> target/linux/x86/config-6.12
    echo 'CONFIG_HZ_1000=y' >> target/linux/x86/config-6.12

    echo 'CONFIG_SCHED_BORE=y' >> target/linux/mediatek/filogic/config-6.12
    echo 'CONFIG_MIN_BASE_SLICE_NS=2000000' >> target/linux/mediatek/filogic/config-6.12
    echo 'CONFIG_SCHED_HRTICK=y' >> target/linux/mediatek/filogic/config-6.12
    echo 'CONFIG_SCHED_AUTOGROUP=y' >> target/linux/mediatek/filogic/config-6.12
    echo 'CONFIG_PREEMPT_VOLUNTARY=y' >> target/linux/mediatek/filogic/config-6.12
    echo 'CONFIG_HZ_1000=y' >> target/linux/mediatek/filogic/config-6.12
    echo "✔ [步骤 6] 编译前最终配置调整 执行完毕。"
}

#分函数 7：下载编译所需文件
function task_step_7() {

    echo "正在执行 [步骤 7]: 下载编译所需文件..."
    cd $GITHUB_WORKSPACE/openwrt
    make defconfig
    make download -j8
    find dl -size -1024c -exec ls -l {} \;
    find dl -size -1024c -exec rm -f {} \;
    echo "✔ [步骤 7] 下载编译所需文件 执行完毕。"
}
# ==========================================
# 主函数 (Main Function)
# ==========================================
function main() {
    echo -e "==========================================="
    echo -e "      开始执行 GitHub Actions 脚本工作流      "
    echo -e "==========================================="

    # 利用 GitHub Actions 的 ::group:: 语法，可以在 CI 日志界面生成可折叠的日志区块

    echo "::group::[1/7] Step 1: 初始化工作环境，克隆源码"
    task_step_1
    echo "::endgroup::"

    echo "::group::[2/7] Step 2: 添加feeds源"
    task_step_2
    echo "::endgroup::"

    echo "::group::[3/7] Step 3: 添加额外软件包，并执行 feeds install和feeds install"
    task_step_3
    echo "::endgroup::"

    echo "::group::[4/7] Step 4: 添加mihomo smart内核"
    task_step_4
    echo "::endgroup::"

    echo "::group::[5/7] Step 5: 合入自定义补丁"
    task_step_5
    echo "::endgroup::"

    echo "::group::[6/7] Step 6: 编译前最终配置调整"
    task_step_6
    echo "::endgroup::"

    echo "::group::[7/7] Step 7: 下载编译所需文件"
    task_step_7
    echo "::endgroup::"


    echo -e "==========================================="
    echo -e "      🎉 所有任务执行完成！(Success)         "
    echo -e "==========================================="
}

# 触发主函数，并将所有脚本参数传递给主函数
main "$@"