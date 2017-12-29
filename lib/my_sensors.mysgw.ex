defmodule MySensors.MySGW do
  @moduledoc """
  Wrapper around the Linux mysgw program.
  """

  use GenServer
  require Logger

  @log_level Application.get_env(:my_sensors_mysgw, :mysgw_log_level, :debug)

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init([]) do
    exe = Path.join([:code.priv_dir(:my_sensors_mysgw), "my_sensors/mysgw"])
    port_opts = [
      :binary,
      :exit_status,
      :stderr_to_stdout,
      {:line, 255},
      {:args, ["-d"]}
    ]
    port = Port.open({:spawn_executable, exe}, port_opts)
    {:ok, port}
  end

  def handle_info({_port, {:data, {:eol, data}}}, state) do
    case @log_level do
      :info ->
        Logger.info data
      :debug ->
        Logger.debug data
      _ -> :ok
    end
    {:noreply, state}
  end

  def handle_info({_, {:exit_status, status}}, state) do
    {:stop, status, state}
  end

  def handle_info(info, state) do
    {:stop, {:unexpected_info, info}}
  end

  def terminate(reason, _state) do
    Logger.error "mysgw died: #{inspect reason}"
  end
end
