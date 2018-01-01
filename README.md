Elixir wrapper around [MySensors](https://github.com/mysensors/MySensors).

# Usage
The [package](https://hex.pm/packages/my_sensors_mysgw) can be installed by adding `my_sensors_mysgw` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:my_sensors_mysgw, "~> 0.1.0"}
  ]
end
```

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
Currently only works for devices with a spidev Linux device, or BCM2835 devices.
