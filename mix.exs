defmodule MySensors.MySGW.Mixfile do
  use Mix.Project

  def project do
    [
      app: :my_sensors_mysgw,
      compilers: compilers(),
      make_clean: ["clean"],
      make_env: %{"MIX_TARGET" => System.get_env("MIX_TARGET")},
      version: "0.1.0",
      elixir: "~> 1.5",
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
    ]
  end
end
