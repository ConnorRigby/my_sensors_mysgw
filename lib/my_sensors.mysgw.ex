defmodule MySensors.MySGW do
  @moduledoc """
  Wraps `mysgw`.
  """

  use GenServer
  require Logger
  alias MySensors.MySGW.Logger, as: MyLogger

  @doc "Start the gateway manually."
  def start_gw(%MyLogger{} = logger) do
    # default = [
    #   eeprom_file: "/tmp/mysensors.eeprom",
    #   config_file: "/tmp/mysensors.conf"
    # ]
    # env = Application.get_env(:my_sensors_mysgw, __MODULE__, [])
    # config = Keyword.merge(default, env)

    # config_file_contents = EEx.eval_file(config_template(), config)
    # :ok = File.write!(config[:config_file], config_file_contents)
    MuonTrap.cmd(exe(), [], into: IO.stream(:stdio, :line), stderr_to_stdout: true)
  end

  @doc false
  def start_link([]) do
    GenServer.start_link(__MODULE__, default_logger(), name: __MODULE__)
  end

  @doc false
  def init(%MyLogger{} = logger) do
    pid = spawn_link(__MODULE__, :start_gw, [logger])
    ref = Process.monitor(pid)
    {:ok, {ref, pid}}
  end

  @doc false
  def handle_info({:DOWN, ref, :process, pid, reason}, {ref, pid}) do
    {:stop, reason, {ref, pid}}
  end

  @doc false
  def terminate(_, _) do
    Logger.error("mysgw: exit")
  end

  @doc false
  def default_logger do
    lconfig = Application.get_env(:my_sensors_mysgw, MyLogger, [])

    %MyLogger{
      level: lconfig[:level] || :info,
      meta: lconfig[:meta] || []
    }
  end

  defp exe do
    Application.app_dir(:my_sensors_mysgw, ["priv", "my_sensors", "mysgw"])
  end

  defp config_template do
    Application.app_dir(:my_sensors_mysgw, ["priv", "mysensors.conf.eex"])
  end
end
