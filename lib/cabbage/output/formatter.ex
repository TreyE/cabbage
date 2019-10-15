defmodule Cabbage.Output.Formatter do
  defmacro __using__(_) do
    quote do
      use GenServer

      @behaviour Cabbage.Output.Formatter

      def start_link() do
        GenServer.start(__MODULE__, [], name: __MODULE__)
      end

      @impl true
      def init(_) do
        init_formatter()
      end

      @impl true
      def handle_call({:suite_start, _} = event, _from, state) do
        new_state = suite_start(state, event)
        {:reply, :ok, new_state}
      end

      def handle_call({:suite_end, _} = event, _from, state) do
        new_state = suite_end(state, event)
        {:reply, :ok, new_state}
      end

      def handle_call({:feature_start, _} = event, _from, state) do
        new_state = feature_start(state, event)
        {:reply, :ok, new_state}
      end

      def handle_call({:feature_end, _} = event, _from, state) do
        new_state = feature_end(state, event)
        {:reply, :ok, new_state}
      end

      def handle_call({:scenario_start, _} = event, _from, state) do
        new_state = scenario_start(state, event)
        {:reply, :ok, new_state}
      end

      def handle_call({:scenario_end, _} = event, _from, state) do
        new_state = scenario_end(state, event)
        {:reply, :ok, new_state}
      end

      def handle_call({:scenario_error, _} = event, _from, state) do
        new_state = scenario_error(state, event)
        {:reply, :ok, new_state}
      end

      def handle_call({:step_start, _} = event, _from, state) do
        new_state = step_start(state, event)
        {:reply, :ok, new_state}
      end

      def handle_call({:step_end, _} = event, _from, state) do
        new_state = step_end(state, event)
        {:reply, :ok, new_state}
      end

      def handle_call(:suite_start, _from, state) do
        {:reply, :ok, state}
      end

      def shutdown() do
        GenServer.stop(__MODULE__)
      end

      @spec status_event(event :: Cabbage.Output.StatusEvent.status_event) :: :ok
      def status_event(event) do
        GenServer.call(__MODULE__, event, 30000)
      end

      def suite_start(state, _) do
        state
      end

      def suite_end(state, _) do
        state
      end

      def feature_start(state, _) do
        state
      end

      def feature_end(state, _) do
        state
      end

      def scenario_start(state, _) do
        state
      end

      def scenario_end(state, _) do
        state
      end

      def scenario_error(state, _) do
        state
      end

      def step_start(state, _) do
        state
      end

      def step_end(state, _) do
        state
      end

      defoverridable(
        suite_start: 2,
        suite_end: 2,
        feature_start: 2,
        feature_end: 2,
        scenario_start: 2,
        scenario_end: 2,
        scenario_error: 2,
        step_start: 2,
        step_end: 2
      )
    end
  end

  @callback init_formatter() :: {:ok, any()}
  @callback suite_start(state :: any(), event :: Cabbage.Output.StatusEvent.suite_start) :: any()
  @callback suite_end(state :: any(), event :: Cabbage.Output.StatusEvent.suite_end) :: any()
  @callback feature_start(state :: any(), event :: Cabbage.Output.StatusEvent.feature_start) :: any()
  @callback feature_end(state :: any(), event :: Cabbage.Output.StatusEvent.feature_end) :: any()
  @callback scenario_start(state :: any(), event :: Cabbage.Output.StatusEvent.scenario_start) :: any()
  @callback scenario_end(state :: any(), event :: Cabbage.Output.StatusEvent.scenario_end) :: any()
  @callback scenario_error(state :: any(), event :: Cabbage.Output.StatusEvent.scenario_error) :: any()
  @callback step_start(state :: any(), event :: Cabbage.Output.StatusEvent.step_start) :: any()
  @callback step_end(state :: any(), event :: Cabbage.Output.StatusEvent.step_end) :: any()
end
