Elixir wrapper around [MySensors](https://github.com/mysensors/MySensors).

# Usage
To change the log level:
```elixir
use Mix.Config
config my_sensors_mysgw: mysgw_log_level: :info
```

or to disable:
```elixir
config my_sensors_mysgw: mysgw_log_level: false
```

# Status
Currently only works for devices with a spidev Linux device, or rpi0 or rpi1
