defmodule MySensors.MySGW.Logger do
  @moduledoc false
  alias MySensors.MySGW.Logger, as: MyLogger
  defstruct [level: :debug, meta: []]

  @doc false
  def log(%MyLogger{level: false}), do: :ok

  def log(%MyLogger{} = logger, {:cont, msg}) when is_binary(msg) do
    log(logger, {:cont, String.split(String.trim(msg), "\n")})
  end

  def log(%MyLogger{} = logger, {:cont, [to_log | rest]}) do
    :ok = Logger.bare_log(logger.level, to_log, logger.meta || [])
    log(logger, {:cont, rest})
  end

  def log(%MyLogger{} = logger, {:cont, []}), do: logger

  def log(%MyLogger{} = logger, _), do: logger

  defimpl Collectable do
    def into(original), do: {original, &MyLogger.log/2}
  end
end
