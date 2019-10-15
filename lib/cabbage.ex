defmodule Cabbage do
  @moduledoc """
  """
  def base_path(), do: Application.get_env(:cabbage, :features, "test/features/")
  def global_tags(), do: Application.get_env(:cabbage, :global_tags, []) |> List.wrap()

  use Application

  def start(_type, _args) do
    children = [
      Cabbage.Output
    ]
    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)
    {:ok, pid, pid}
  end

  def prep_stop(s_pid) do
    Cabbage.Output.stop()
    Supervisor.delete_child(s_pid, Cabbage.Output)
  end
end
