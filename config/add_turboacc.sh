#!/usr/bin/env bash
# shellcheck disable=SC2016

trap 'rm -rf "$TMPDIR"' EXIT
TMPDIR=$(mktemp -d) || exit 1

NO_SFE=false
LOCAL_PACKAGE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-sfe)
            NO_SFE=true
            shift
            ;;
        --local-pkg)
            LOCAL_PACKAGE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if ! [ -d "./package" ]; then
    echo "./package not found"
    exit 1
fi

VERSION_NUMBER=$(sed -n '/VERSION_NUMBER:=$(if $(VERSION_NUMBER),$(VERSION_NUMBER),.*)/p' include/version.mk | sed -e 's/.*$(VERSION_NUMBER),//' -e 's/)//')
kernel_versions="$(find "./include" | sed -n '/kernel-[0-9]/p' | sed -e "s@./include/kernel-@@" | sed ':a;N;$!ba;s/\n/ /g')"
if [ -z "$kernel_versions" ]; then
    kernel_versions="$(find "./target/linux/generic" | sed -n '/kernel-[0-9]/p' | sed -e "s@./target/linux/generic/kernel-@@" | sed ':a;N;$!ba;s/\n/ /g')"
fi
if [ -z "$kernel_versions" ]; then
    echo "Error: Unable to get kernel version, script exited"
    exit 1
fi
echo "kernel version: $kernel_versions, No SFE: $NO_SFE"

if [ -d "./package/turboacc" ]; then
    echo "./package/turboacc already exists, delete it? [Y/N]"
    read -r answer
    if [[ $answer =~ ^[Yy]$ ]]; then
        rm -rf "./package/turboacc"
    else
        echo "You selected 'No', script exited"
        exit 0
    fi
fi

git clone --depth=1 --single-branch https://github.com/chenmozhijin/turboacc "$TMPDIR/turboacc/turboacc" || exit 1
if [ -n "$LOCAL_PACKAGE" ]; then
    echo "Using local package: $LOCAL_PACKAGE"
    cp -RT "$LOCAL_PACKAGE" "$TMPDIR/package" || exit 1
else
    git clone --depth=1 --single-branch --branch "package" https://github.com/chenmozhijin/turboacc "$TMPDIR/package" || exit 1
fi

cp -r "$TMPDIR/turboacc/turboacc/luci-app-turboacc" "$TMPDIR/turboacc/luci-app-turboacc"
rm -rf "$TMPDIR/turboacc/turboacc"



    if ! grep -q "CONFIG_NF_CONNTRACK_CHAIN_EVENTS" "./target/linux/generic/config-$kernel_version"; then
        echo "# CONFIG_NF_CONNTRACK_CHAIN_EVENTS is not set" >> "./target/linux/generic/config-$kernel_version"
    fi
    if [ "$NO_SFE" = false ] && ! grep -q "CONFIG_SHORTCUT_FE" "./target/linux/generic/config-$kernel_version"; then
        echo "# CONFIG_SHORTCUT_FE is not set" >> "./target/linux/generic/config-$kernel_version"
    fi
done

cp -r "$TMPDIR/turboacc" "./package/turboacc"

FIREWALL4_VERSION=$(grep -o 'PKG_SOURCE_VERSION:=.*' ./package/network/config/firewall4/Makefile | cut -d '=' -f 2)

rm -rf  ./package/network/config/firewall4 

if ! [ -d "$TMPDIR/package/firewall4-$FIREWALL4_VERSION" ]; then
    echo "firewall4 version $FIREWALL4_VERSION not found, using latest version"
    FIREWALL4_VERSION=$(grep -o 'FIREWALL4_VERSION=.*' "$TMPDIR/package/version" | cut -d '=' -f 2)
fi

cp -RT "$TMPDIR/package/firewall4-$FIREWALL4_VERSION/firewall4" ./package/network/config/firewall4

echo "Finish"
exit 0
