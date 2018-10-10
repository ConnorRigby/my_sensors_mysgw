defmodule MySensors.MySGW.Mixfile do
  use Mix.Project

  def project do
    [
      app: :my_sensors_mysgw,
      compilers: compilers(),
      make_clean: ["clean"],
      make_env: make_env(),
      version: "2.4.0-beta",
      elixir: "~> 1.5",
      description: "Elixir wrapper around [MySensors](https://github.com/mysensors/MySensors)",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp compilers do
    case :init.get_plain_arguments() |> List.last() do
      a when a in ['mix', 'compile', 'firmware', 'clean'] ->
        [:elixir_make] ++ Mix.compilers()

      _ ->
        Mix.compilers()
    end
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex],
      mod: {MySensors.MySGW.Application, []}
    ]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.4", runtime: false},
      {:muontrap, "~> 0.4"},
      {:ex_doc, "~> 0.19", only: :docs}
    ]
  end

  defp make_env do
    config = Mix.Project.config()

    %{
      "MIX_TARGET" => config[:target] || System.get_env("MIX_TARGET") || "host",
      "MY_SENSORS_MYSGW_SPI_DEV" => config[:my_sensors_mysgw_spi_dev] || "/dev/spidev0.0",
      "MY_SENSORS_MYSGW_IRQ_PIN" => config[:my_sensors_mysgw_irq_pin],
      "MY_SENSORS_MYSGW_CS_PIN" => config[:my_sensors_mysgw_cs_pin],
      "MY_SENSORS_MYSGW_CE_PIN" => config[:my_sensors_mysgw_ce_pin]
    }
  end

  defp package do
    [
      licenses: ["MIT", "GPLv2"],
      maintainers: ["konnorrigby@gmail.com"],
      files: [
        "lib",
        "LICENSE.MIT",
        "mix.exs",
        "README.md",
        "Makefile",
        "priv/mysensors.conf.eex",
        "patches/my_sensors/*.patch"
      ],
      links: %{
        "GitHub" => "https://github.com/connorrigby/my_sensors_mysgw",
        "MySensors" => "https://www.mysensors.org/"
      },
      source_url: "https://github.com/connorrigby/my_sensors_mysgw"
    ]
  end
end
