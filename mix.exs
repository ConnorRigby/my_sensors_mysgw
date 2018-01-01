defmodule MySensors.MySGW.Mixfile do
  use Mix.Project

  def project do
    [
      app: :my_sensors_mysgw,
      compilers: compilers(),
      make_clean: ["clean"],
      make_env: %{"MIX_TARGET" => System.get_env("MIX_TARGET") || "NULL"},
      version: "0.1.0",
      elixir: "~> 1.5",
      description: "Elixir wrapper around [MySensors](https://github.com/mysensors/MySensors)",
      package: package(),
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  defp compilers do
    case :init.get_plain_arguments() |> List.last() do
      a when a in ['mix', 'compile', 'firmware', 'clean'] ->
        [:elixir_make] ++ Mix.compilers
      _ -> Mix.compilers
    end
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {MySensors.MySGW.Application, []}
    ]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.4.0", runtime: false},
      {:ex_doc, "~> 0.18.1"},
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["konnorrigby@gmail.com"],
      links: %{
        "GitHub" => "https://github.com/connorrigby/my_sensors",
        "MySensors" => "https://www.mysensors.org/"
        },
      source_url: "https://github.com/connorrigby/my_sensors_mysgw"
    ]
  end
end
