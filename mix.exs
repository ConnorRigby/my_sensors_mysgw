defmodule MySensorsTransportRpi.Mixfile do
  use Mix.Project

  def project do
    [
      app: :my_sensors_transport_rpi,
      compilers: [:elixir_make] ++ Mix.compilers,
      make_clean: ["clean"],
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_make, "~> 0.4.0", runtime: false},
      # {:my_sensors, "~> 0.1.0-rc1", runtime: false}
    ]
  end
end
