# MySensors.MySGW
## What is it?
An Elixir wrapper around [MySensors]
(https://github.com/mysensors/MySensors).
specifically `mysgw`. This allows driving the `nrf24` chip directly off the
SPI bus on Nerves devices.

## Why is it?
[The default `mysgw` configure script](https://github.com/mysensors/MySensors/blob/2.3.0/configure)
doesn't easily allow for cross-compilation. (Something that Nerves requires).
A couple source file also need to be patched to allow for Erlang to start the
program as a `port`. See these threads for more info on this:
* https://github.com/mysensors/MySensors/issues/1022
* https://github.com/mysensors/MySensors/pull/1061

## Usage and Configuration
```elixir
# Disable logs
config :my_sensors_mysgw, MySensors.MySGW.Logger, [
  level: false
]

# Configure meta information
config :my_sensors_mysgw, MySensors.MySGW.Logger, [
  level: :info,
  meta: [:some, "cool", 'info']
]

# Don't start the daemon.
config :my_sensors_mysgw, MySensors.MySGW.Application, [
  daemon: false
]
# Start the daemon later: (this is blocking, spawn it)
MySensors.MySGW.start_gw()

# Configure eeprom + config_file location
config :my_sensors_mysgw, MySensors.MySGW, [
  eeprom_file: "/root/mysensors.eeprom",
  config_file: "/root/mysensors.conf"
]
```

### Raspberry Pi
For Raspberry Pi devices you can follow
[the guide provided by mysensors]
(https://www.mysensors.org/build/raspberry#wiring)

### Beaglebone
There is no wiring guide for beaglebone based devices. Wiring is similar
to Raspberry Pi. Match the pin names between the radio and beaglebone.
You will also need to set `my_sensors_mysgw_spi_dev` in your `mix.exs` project config.
```elixir
def project do
    [
      # ...
      my_sensors_mysgw_spi_dev: "/dev/spidev1.0",
      # ...
    ]
end
```

### CS, CE, Interrupt
You will probably need to configure your the pins outside of `spi_dev`.
```elixir
def project do
    [
      # ...
      my_sensors_mysgw_spi_dev: "/dev/spidevStopCopyPastingThings",
      my_sensors_mysgw_irq_pin: 9000,
      my_sensors_mysgw_cs_pin:  9001,
      my_sensors_mysgw_ce_pin:  9002,
      # ...
    ]
end
```

## Usage with `my_sensors`
If you are running `my_sensors` on the same device as `my_sensors_mysgw`:
```elixir
iex()> MySensors.Gateway.add_transport(MySensors.Transport.TCP, [])
```
otherwise:
```elixir
iex()> MySensors.Gateway.add_transport(MySensors.Transport.TCP, [host: 'nerves.local'])
```