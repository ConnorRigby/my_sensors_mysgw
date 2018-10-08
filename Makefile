CWD=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
CC ?= $(CROSSCOMPILER)-gcc
CXX ?= $(CROSSCOMPILER)-g++
MIX_TARGET ?= NULL

ifeq ($(MY_SENSORS_MYSGW_SPI_DEV), )
MY_SENSORS_MYSGW_SPI_DEV=/dev/spidev0.0
$(info using default spi device $(MY_SENSORS_MYSGW_SPI_DEV))
endif

MY_SENSORS_CONFIG=\
	--c_compiler=$(CC) \
	--cxx_compiler=$(CXX) \
	--my-transport=nrf24 \
	--my-config-file=/tmp/mysensors.conf \
	--my-debug=enable \
	--my-serial-is-pty \
	--my-signing=none \
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

else ifeq ($(MIX_TARGET),$(filter $(MIX_TARGET),rpi2))
$(info Using BCM2836 config.)
MY_SENSORS_CONFIG +=\
	--cpu-flags="-march=armv7-a -mtune=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard" \
	--extra-cflags="-DLINUX_ARCH_RASPBERRYPI" \
	--extra-cxxflags="-std=c++98" \
	--soc="BCM2836" \
	--spi-driver="BCM"

else ifeq ($(MIX_TARGET),$(filter $(MIX_TARGET),rpi3))
$(info Using BCM2837 config.)
MY_SENSORS_CONFIG +=\
	--cpu-flags="-march=armv8-a+crc -mtune=cortex-a53 -mfpu=neon-fp-armv8 -mfloat-abi=hard" \
	--extra-cflags="-DLINUX_ARCH_RASPBERRYPI" \
	--extra-cxxflags="-std=c++98" \
	--soc="BCM2837" \
	--spi-driver="BCM"

else ifeq ($(MIX_TARGET),$(filter $(MIX_TARGET),bbb))
$(info Using am335x config.)
MY_SENSORS_CONFIG +=\
	--cpu-flags="-march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=hard" \
	--extra-cxxflags="-std=c++98" \
	--soc="AM33XX" \
	--spi-driver="SPIDEV" \
	--spi-spidev-device=$(MY_SENSORS_MYSGW_SPI_DEV)
else
$(info Using generic spidev config.)
MY_SENSORS_CONFIG +=\
	--cpu-flags="" \
	--extra-cxxflags="-std=c++98" \
	--soc="unknown" \
	--spi-driver="SPIDEV" \
	--spi-spidev-device=$(MY_SENSORS_MYSGW_SPI_DEV)
endif

# MY_SENSORS_PATCHES := $(patsubst %.patch,%.patched,$(wildcard patches/my_sensors/*.patch))
# MY_SENSORS_PATCHES := $(patsubst %.patch,%.patched,$(wildcard patches/my_sensors/*.patch))

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
