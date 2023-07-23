#!/usr/bin/env bash

if [ -d openwrt ]; then
  rm -rf openwrt
fi

git clone https://github.com/openwrt/openwrt.git -b v22.03.5 --recursive
pushd openwrt

./scripts/feeds update -a
./scripts/feeds install -a

patch -p0 < ../patches/fix-resize.patch
cp ../.config .

make -j$(nproc)
popd

