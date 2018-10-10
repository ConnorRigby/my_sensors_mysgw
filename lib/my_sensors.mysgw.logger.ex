defmodule MySensors.MySGW.Logger do
  @moduledoc false
  alias MySensors.MySGW.Logger, as: MyLogger
  defstruct level: :debug, meta: [module: :my_sensors_mysgw]

  @doc false
  def log(%MyLogger{level: false}), do: :ok

  def log(%MyLogger{} = logger, {:cont, msg}) when is_binary(msg) do
    msg = String.trim(msg)
    log(logger, {:cont, Regex.split(~r(\w{3}\s\d{2}\s\d{2}:\d{2}:\d{2}\s), msg)})
  end

  # Empty string because i don't know how2regex
  def log(%MyLogger{} = logger, {:cont, ["" | rest]}) do
    log(logger, {:cont, rest})
  end

  def log(%MyLogger{} = logger, {:cont, [msg | rest]}) do
    case decode(msg) do
      {level, msg} ->
        :ok = Logger.bare_log(level, String.trim(msg), logger.meta)

      _ ->
        :ok
    end

    log(logger, {:cont, rest})
  end

  def log(%MyLogger{} = logger, {:cont, []}), do: logger

  def log(%MyLogger{} = logger, _), do: logger

  def decode("EMERGENCY " <> msg), do: {:error, msg}
  def decode("ALERT " <> msg), do: {:error, msg}
  def decode("CRITICAL " <> msg), do: {:error, msg}
  def decode("ERROR " <> msg), do: {:error, msg}
  def decode("WARNING " <> msg), do: {:warn, msg}
  def decode("NOTICE " <> msg), do: {:info, msg}
  def decode("INFO " <> msg), do: {:info, msg}
  def decode("DEBUG " <> msg), do: {:debug, msg}
  def decode(_), do: nil

  defimpl Collectable do
    def into(original), do: {original, &MyLogger.log/2}
  end
end
