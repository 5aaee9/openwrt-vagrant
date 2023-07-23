#!/usr/bin/env bash

if [ -d openwrt ]; then
  git clone https://github.com/openwrt/openwrt.git -b v22.03.5 --recursive
else
  pushd openwrt
  git pull
  popd
fi

pushd openwrt

./scripts/feeds update -a
./scripts/feeds install -a

patch -p0 < ../patches/fix-resize.patch
cp ../.config .

make -j$(nproc)
popd

