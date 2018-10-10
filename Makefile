CWD=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
CC ?= $(CROSSCOMPILER)-gcc
CXX ?= $(CROSSCOMPILER)-g++
MIX_TARGET ?= NULL

ifeq ($(MY_SENSORS_MYSGW_SPI_DEV), )
MY_SENSORS_MYSGW_SPI_DEV=/dev/spidev0.0
$(info using default spi device $(MY_SENSORS_MYSGW_SPI_DEV))
endif

ifeq ($(MY_SENSORS_MYSGW_IRQ_PIN),)
else
MY_SENSORS_PIN_CONFIG += --my-rf24-irq-pin=$(MY_SENSORS_MYSGW_IRQ_PIN)
endif

ifeq ($(MY_SENSORS_MYSGW_CS_PIN),)
else
MY_SENSORS_PIN_CONFIG += --my-rf24-cs-pin=$(MY_SENSORS_MYSGW_CS_PIN)
endif

ifeq ($(MY_SENSORS_MYSGW_CE_PIN),)
else
MY_SENSORS_PIN_CONFIG += --my-rf24-ce-pin=$(MY_SENSORS_MYSGW_CE_PIN)
endif

MY_SENSORS_CONFIG=\
	--c_compiler=$(CC) \
	--cxx_compiler=$(CXX) \
	--extra-cflags="-DLOG_DISABLE_COLOR" \
	--extra-cxxflags="-std=c++98" \
	--my-gateway=ethernet \
	--my-transport=rf24 \
	--my-config-file=/tmp/mysensors.conf \
	--my-debug=enable \
	--my-signing=none \
	--bin-dir=$(CWD)/priv/my_sensors \
	--build-dir=$(CWD)/_build/my_sensors \
	--prefix=$(CWD)/priv/my_sensors \
	$(MY_SENSORS_PIN_CONFIG)

ifeq ($(MIX_TARGET),$(filter $(MIX_TARGET),rpi rpi0))
$(info Using BCM2835 config.)
MY_SENSORS_CONFIG +=\
	--cpu-flags="-march=armv6zk -mtune=arm1176jzf-s -mfpu=vfp" \
	--extra-cflags="-DLINUX_ARCH_RASPBERRYPI" \
	--soc="BCM2835" \
	--spi-driver="BCM"

else ifeq ($(MIX_TARGET),$(filter $(MIX_TARGET),rpi2))
$(info Using BCM2836 config.)
MY_SENSORS_CONFIG +=\
	--cpu-flags="-march=armv7-a -mtune=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard" \
	--extra-cflags="-DLINUX_ARCH_RASPBERRYPI" \
	--soc="BCM2836" \
	--spi-driver="BCM"

else ifeq ($(MIX_TARGET),$(filter $(MIX_TARGET),rpi3))
$(info Using BCM2837 config.)
MY_SENSORS_CONFIG +=\
	--cpu-flags="-march=armv8-a+crc -mtune=cortex-a53 -mfpu=neon-fp-armv8 -mfloat-abi=hard" \
	--extra-cflags="-DLINUX_ARCH_RASPBERRYPI" \
	--soc="BCM2837" \
	--spi-driver="BCM"

else ifeq ($(MIX_TARGET),$(filter $(MIX_TARGET),bbb))
$(info Using am335x config.)
MY_SENSORS_CONFIG +=\
	--cpu-flags="-march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=hard" \
	--soc="AM33XX" \
	--spi-driver="SPIDEV" \
	--spi-spidev-device=$(MY_SENSORS_MYSGW_SPI_DEV)
else
$(info Using generic spidev config.)
MY_SENSORS_CONFIG +=\
	--cpu-flags="" \
	--soc="unknown" \
	--spi-driver="SPIDEV" \
	--spi-spidev-device=$(MY_SENSORS_MYSGW_SPI_DEV)
endif

MY_SGW := $(CWD)/priv/my_sensors/mysgw
MY_SENSORS_PATCHES := $(patsubst %.patch,%.patched,$(wildcard $(CWD)/patches/my_sensors/*.patch))
MY_SENSORS_SUBMODULE_VERSION := 5d159a6c57209e9be91834b498d0072d3a1a25d6
MY_SENOSRS_SUBMODULE := $(CWD)/c_src/MySensors
MY_SENSORS_URL := https://github.com/mysensors/MySensors/archive/$(MY_SENSORS_SUBMODULE_VERSION).tar.gz

.PHONY: all clean clean_my_sensors_patches my_sensors
.DEFAULT_GOAL: all

all: $(MY_SGW)

# Don't use git apply here.
# https://stackoverflow.com/questions/24821431/git-apply-patch-fails-silently-no-errors-but-nothing-happens
%.patched:
	cd $(CWD) && patch -p1 < $(patsubst %.patched,%.patch,$@)
	touch $@

ifeq ($(shell if [ -d ".git" ]; then echo "git"; else echo "hex"; fi ), git)
# If the .git dir exists, this was a git clone
$(MY_SENOSRS_SUBMODULE):
	@[ "$(ls -A $(MY_SENOSRS_SUBMODULE))" ] && : || git submodule update --init --recursive

else

# if not, this is a hex package (probably)
$(MY_SENOSRS_SUBMODULE):
	mkdir -p c_src/
	wget $(MY_SENSORS_URL) -O - | tar -xz -C c_src/
	cd c_src/MySensors-$(MY_SENSORS_SUBMODULE_VERSION) && git init . && git add . && git commit -am "Fake"
	mv c_src/MySensors-$(MY_SENSORS_SUBMODULE_VERSION) $(MY_SENOSRS_SUBMODULE)

endif

$(MY_SGW): $(MY_SENOSRS_SUBMODULE) $(MY_SENSORS_PATCHES)
	cd $(MY_SENOSRS_SUBMODULE) && ./configure $(MY_SENSORS_CONFIG) && make

clean_my_sensors_patches:
	@cd $(MY_SENOSRS_SUBMODULE) && git stash && git stash drop ; :
	rm -f patches/my_sensors/*.patched

clean: clean_my_sensors_patches
	rm -rf priv/my_sensors
