#!/sbin/sh

# This file contains parts from the scripts taken from the Open GApps Project by mfonville.
#
# The Open GApps scripts are free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# These scripts are distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# Functions & variables
tmp_path=/tmp

file_getprop() { grep "^$2" "$1" | cut -d= -f2; }

rom_build_prop=/system/build.prop

arch=$(file_getprop $rom_build_prop "ro.product.cpu.abi=")

# PrebuiltGmsCore
if (echo "$arch" | grep -qi "armeabi"); then
  cp -rf $tmp_path/hangouts/arm/* /system
elif (echo "$arch" | grep -qi "arm64"); then
  cp -rf $tmp_path/hangouts/arm64/* /system
fi

# Cleanup
rm -rf /tmp/hangouts
