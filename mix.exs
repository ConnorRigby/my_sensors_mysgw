defmodule MySensors.MySGW.Mixfile do
  use Mix.Project

  def project do
    [
      app: :my_sensors_mysgw,
      compilers: compilers(),
      make_clean: ["clean"],
      make_env: make_env(),
      version: "2.4.0-beta.3",
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
      "MY_SPIDEV_DEVICE" => config[:my_sensors_spidev_device],
      "MY_TRANSPORT" => config[:my_sensors_transport],
      "MY_SENSORS_IRQ_PIN" => config[:my_sensors_irq_pin],
      "MY_SENSORS_CS_PIN" => config[:my_sensors_cs_pin],
      "MY_SENSORS_CE_PIN" => config[:my_sensors_ce_pin],
      "MY_SENSORS_ERR_LED_PIN" => config[:my_sensors_err_led_pin],
      "MY_SENSORS_RX_LED_PIN" => config[:my_sensors_rx_led_pin],
      "MY_SENSORS_TX_LED_PIN" => config[:my_sensors_tx_led_pin],
      "MY_RF24_PA_LEVEL" => config[:my_sensors_rf24_pa_level] || "RF24_PA_LOW",
      "MY_IS_RFM69HW" => config[:my_sensors_rfm69hw],
      "MY_LEDS" => config[:my_sensors_leds],
      "MY_LEDS_INVERSE" => config[:my_sensors_leds_inverse]
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
