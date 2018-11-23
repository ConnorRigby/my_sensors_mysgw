CWD=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
CC ?= $(CROSSCOMPILER)-gcc
CXX ?= $(CROSSCOMPILER)-g++
MIX_TARGET ?= NULL

ifeq ($(MY_SPIDEV_DEVICE), )
MY_SPIDEV_DEVICE=/dev/spidev0.0
$(info using default spi device $(MY_SPIDEV_DEVICE))
endif

ifeq ($(MY_TRANSPORT), )
$(warn MY_TRANSPORT required)
endif


MY_SENSORS_CONFIG=\
	--c_compiler=$(CC) \
	--cxx_compiler=$(CXX) \
	--extra-cflags="-DLOG_DISABLE_COLOR" \
	--extra-cxxflags="-std=c++98" \
	--my-gateway=ethernet \
	--my-config-file=/tmp/mysensors.conf \
	--my-debug=enable \
	--my-signing=none \
	--bin-dir=$(CWD)/priv/my_sensors \
	--build-dir=$(CWD)/_build/my_sensors \
	--no_init_system \
	--prefix=$(CWD)/priv/my_sensors

# RF24
ifeq ($(MY_TRANSPORT),$(filter $(MY_TRANSPORT),rf24))
MY_RF24_CONFIG=\
	--my-transport=rf24 \
	--my-rf24-irq-pin=$(MY_SENSORS_IRQ_PIN) \
	--my-rf24-cs-pin=$(MY_SENSORS_CS_PIN) \
	--my-rf24-ce-pin=$(MY_SENSORS_CE_PIN)

$(info Using RF24 transport: $(MY_RF24_CONFIG))

ifeq ($(MY_RF24_PA_LEVEL),$(filter $(MY_RF24_PA_LEVEL),RF24_PA_MAX))
$(info Using RF24_PA_MAX)
MY_RF24_CONFIG += --my-rf24-pa-level=RF24_PA_MAX
else ifeq ($(MY_RF24_PA_LEVEL),$(filter $(MY_RF24_PA_LEVEL),RF24_PA_LOW))
MY_RF24_CONFIG += --my-rf24-pa-level=RF24_PA_LOW
endif

MY_SENSORS_CONFIG += $(MY_RF24_CONFIG)
# RF24

# RFM69
else ifeq ($(MY_TRANSPORT),$(filter $(MY_TRANSPORT),rfm69))
MY_RFM69_CONFIG=\
	--my-transport=rfm69 \
	--my-rfm69-irq-pin=$(MY_SENSORS_IRQ_PIN) \
	--my-rfm69-cs-pin=$(MY_SENSORS_CS_PIN)

$(info Using RFM69 transport $(MY_RFM69_CONFIG))

ifeq ($(MY_IS_RFM69HW),true)
$(info Enabling RFM69HW)

MY_RFM69_CONFIG += --my-is-rfm69hw
endif
MY_SENSORS_CONFIG += $(MY_RFM69_CONFIG)
#RFM69

# RFM95
else ifeq ($(MY_TRANSPORT),$(filter $(MY_TRANSPORT),rfm95))
MY_RFM95_CONFIG=\
	--my-transport=rfm95 \
	--my-rfm95-irq-pin=$(MY_SENSORS_IRQ_PIN) \
	--my-rfm95-cs-pin=$(MY_SENSORS_CS_PIN)

$(info Using RFM95 transport $(MY_RFM95_CONFIG))
MY_SENSORS_CONFIG += $(MY_RFM95_CONFIG)
# RFM85
endif
# TRANSPORT

ifeq ($(MY_LEDS),true)
$(info enabling LEDS: $(MY_LEDS))
MY_LEDS_CONFIG=\
	--my-leds-err-pin=$(MY_SENSORS_ERR_LED_PIN) \
	--my-leds-rx-pin=$(MY_SENSORS_RX_LED_PIN) \
	--my-leds-tx-pin=$(MY_SENSORS_TX_LED_PIN)

ifeq ($(MY_LEDS_INVERSE),true)
$(info inverting leds)
MY_LEDS_CONFIG+=--my-leds-blinking-inverse
endif
MY_SENSORS_CONFIG += $(MY_LEDS_CONFIG)
endif

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
	--spi-spidev-device=$(MY_SPIDEV_DEVICE)

else
$(info Using generic spidev config.)
MY_SENSORS_CONFIG +=\
	--cpu-flags="" \
	--soc="unknown" \
	--spi-driver="SPIDEV" \
	--spi-spidev-device=$(MY_SPIDEV_DEVICE)

endif

MY_SGW := $(CWD)/priv/my_sensors/mysgw
# MY_SENSORS_PATCHES := $(patsubst %.patch,%.patched,$(wildcard patches/my_sensors/*.patch))
MY_SENSORS_SUBMODULE := c_src/MySensors

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
$(MY_SENSORS_SUBMODULE):
	@[ "$(ls -A $(MY_SENSORS_SUBMODULE))" ] && : || git submodule update --init --recursive

else

# if not, this is a hex package (probably)
$(MY_SENSORS_SUBMODULE):
	mkdir -p c_src/
	wget $(MY_SENSORS_URL) -O - | tar -xz -C c_src/
	cd c_src/MySensors-$(MY_SENSORS_SUBMODULE_VERSION) && git init . && git add . && git commit -am "Fake"
	mv c_src/MySensors-$(MY_SENSORS_SUBMODULE_VERSION) $(MY_SENSORS_SUBMODULE)

endif

$(MY_SGW): $(MY_SENSORS_SUBMODULE) $(MY_SENSORS_PATCHES)
	cd $(MY_SENSORS_SUBMODULE) && ./configure $(MY_SENSORS_CONFIG) && make

clean_my_sensors_patches:
	@cd $(MY_SENSORS_SUBMODULE) && git stash && git stash drop ; :
	rm -f patches/my_sensors/*.patched

clean: clean_my_sensors_patches
	rm -rf priv/my_sensors
