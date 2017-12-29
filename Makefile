CWD=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
CC ?= $(CROSSCOMPILER)-gcc
CXX ?= $(CROSSCOMPILER)-g++
MIX_TARGET ?= NULL

MY_SENSORS_CONFIG=\
	--c_compiler=$(CC) \
	--cxx_compiler=$(CXX) \
	--my-transport=nrf24 \
	--my-config-file=/tmp/mysensors.dat \
	--my-debug=enable \
	--my-serial-is-pty \
	--bin-dir=$(CWD)/priv/my_sensors \
	--build-dir=$(CWD)/_build/my_sensors \
	--prefix=$(CWD)/priv/my_sensors

ifeq ($(MIX_TARGET),$(filter $(MIX_TARGET),rpi rpi0))
$(info Using BCM2835 config.)
MY_SENSORS_CONFIG +=\
	--cpu-flags="-march=armv6zk -mtune=arm1176jzf-s -mfpu=vfp" \
	--extra-cflags="-DLINUX_ARCH_RASPBERRYPI" \
	--extra-cxxflags="-std=c++98" \
	--soc="BCM2835" \
	--spi-driver="BCM"
endif

MY_SENSORS_PATCHES := $(patsubst %.patch,%.patched,$(wildcard patches/my_sensors/*.patch))

all: my_sensors

%.patched:
	git apply $(patsubst %.patched,%.patch,$@)
	touch $@

my_sensors_submodule:
	@[ "$(ls -A c_src/MySensors)" ] && : || git submodule update --init --recursive

my_sensors: my_sensors_submodule $(MY_SENSORS_PATCHES)
	cd ./c_src/MySensors && ./configure $(MY_SENSORS_CONFIG) && make

clean_my_sensors_patches:
	@cd ./c_src/MySensors && git stash && git stash drop ; :
	rm -f patches/my_sensors/*.patched

clean: clean_my_sensors_patches
	rm -rf priv/my_sensors
