[中文](https://p3terx.com/archives/build-openwrt-with-github-actions.html)

# Actions-OpenWrt

[![LICENSE](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square&label=LICENSE)](https://github.com/P3TERX/Actions-OpenWrt/blob/master/LICENSE)
![GitHub Stars](https://img.shields.io/github/stars/P3TERX/Actions-OpenWrt.svg?style=flat-square&label=Stars&logo=github)
![GitHub Forks](https://img.shields.io/github/forks/P3TERX/Actions-OpenWrt.svg?style=flat-square&label=Forks&logo=github)

A template for building OpenWrt with GitHub Actions

## My default config
项目release的固件除openwrt默认包含的组件外还含有以下内容：ipv6-helper、luci-app-filetransfer、BORE CPU Scheduler、SmartDNS、OPENCLASH（内置mihomo alpha内核）、DiskMan、TurboACC（支持firewall4）、BBR3补丁（有效性待确认）、taskplan（任务计划）、my-script（一个启动脚本，为了切换qdisc算法）、luci-app-temp-status（温度）、luci-theme-argon（主题）、重启插件、关机插件。

## Usage

重要文件说明：

*[diy-part1.sh] ---------->克隆openwrt源码后的第一个脚本，此时feeds文件夹为空，不能对feeds进行修改，但可以对openwrt源码进行修改，建议在这里加入你的feeds链接。

*[diy-part2.sh] ---------->更新和安装feeds后的脚本，可以对feeds进行修改，修改feeds后记得再次执行update和install，建议在这里加入feeds里没有但你想要额外添加的插件。

*[diy-part3.sh] ---------->编译前的最后一个脚本，此时可以对整个要编译的源码进行修改，建议在这里添加你对openwrt源码的自定义设置。

*[.config] --------------->OpenWrt构建系统的主要配置文件，从make menuconfig生成，你可以生成自己的配置并上传代替本项目中的配置。（我的配置请看上方My default config的说明）

*[perest-clash-core.sh] -->将mihomo内核放置到正确的位置的脚本，目前已弃置，所有脚本已集成到action脚本中。


目录：

|->本项目

  |->.github ---->放置action运行脚本。
  
  |->config ----->放置所有需要的文件。
  
    |->files ---->放置你要添加的文件。
	
	|->rax3000m-->放置rax3000m的.config文件。
	
	|->x86 ------>放置x86的.config文件。
	

## Credits

- [Microsoft Azure](https://azure.microsoft.com)
- [GitHub Actions](https://github.com/features/actions)
- [OpenWrt](https://github.com/openwrt/openwrt)
- [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)
- [Mikubill/transfer](https://github.com/Mikubill/transfer)
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release)
- [Mattraks/delete-workflow-runs](https://github.com/Mattraks/delete-workflow-runs)
- [dev-drprasad/delete-older-releases](https://github.com/dev-drprasad/delete-older-releases)
- [peter-evans/repository-dispatch](https://github.com/peter-evans/repository-dispatch)

## License

[MIT](https://github.com/P3TERX/Actions-OpenWrt/blob/main/LICENSE) © [**P3TERX**](https://p3terx.com)
