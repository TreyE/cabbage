defmodule Cabbage.Output do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    format_module_list = Application.get_env(:cabbage, :formatters, [])
    Enum.each(format_module_list, fn(mod) ->
      mod.start_link()
    end)
    Enum.each(format_module_list, fn(mod) ->
      mod.status_event({:suite_start, :ok})
    end)
    {:ok, format_module_list}
  end

  @impl true
  def handle_call(event, _from, state) do
    Enum.each(state, fn(m) ->
      m.status_event(event)
    end)
    {:reply, :ok, state}
  end

  @impl true
  def terminate(_, state) do
    Enum.each(state, fn(mod) ->
      mod.status_event({:suite_end, :ok})
    end)
    Enum.each(state, fn(mod) ->
      mod.shutdown()
    end)
  end

  @spec scenario_status(any) :: any
  def scenario_status(e) do
    GenServer.call(__MODULE__, e, 30000)
  end
end
