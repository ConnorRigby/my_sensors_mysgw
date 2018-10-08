defmodule MySensors.MySGW.Application do
  @moduledoc false
  use Application

  @doc false
  def start(_type, _args) do
    config = Application.get_env(:my_sensors_mysgw, __MODULE__, [])
    children = if config[:daemon] == false, do: [], else: [{MySensors.MySGW, []}]
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
