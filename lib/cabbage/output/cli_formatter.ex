defmodule Cabbage.Output.CliFormatter do
  use Cabbage.Output.Formatter

  defmodule CliFormatterState do
    defstruct [
      current_steps: %{},
      current_scenarios: %{}
    ]

    def enqueue_step(rec, feature, scenario, step, step_index) do
      new_steps = Map.put(rec.current_steps, {feature.name, scenario.name}, {step_index, step})
      %__MODULE__{
        rec |
          current_steps: new_steps
      }
    end

    def enqueue_scenario(rec, feature, scenario) do
      f_scenarios = Map.get(rec.current_scenarios, feature.name, [])
      new_scenarios = Map.put(rec.current_scenarios, feature.name, f_scenarios ++ [scenario.name])
      %__MODULE__{
        rec |
          current_scenarios: new_scenarios
      }
    end

    def pop_step(rec, feature, scenario) do
      new_steps = Map.delete(rec.current_steps, {feature.name, scenario.name})
      %__MODULE__{
        rec |
          current_steps: new_steps
      }
    end

    def pop_scenario(rec, feature, scenario) do
      new_steps = Map.delete(rec.current_steps, {feature.name, scenario.name})
      f_scenarios = Map.get(rec.current_scenarios, feature.name, [])
      new_scenarios = Map.put(rec.current_scenarios, feature.name, f_scenarios -- [scenario.name])
      %__MODULE__{
        rec |
          current_steps: new_steps,
          current_scenarios: new_scenarios
      }
    end

    def incomplete_step(rec, feature, scenario) do
      Map.get(rec.current_steps, {feature.name, scenario.name}, nil)
    end

    def incomplete_scenarios(rec, feature) do
      Map.get(rec.current_scenarios, feature.name, nil)
    end

    def pop_feature(rec, feature) do
      new_scenarios = Map.delete(rec.current_scenarios, feature.name)
      %__MODULE__{
        rec |
          current_scenarios: new_scenarios
      }
    end

    def step_for_scenario(rec, feature, scenario_name) do
      Map.get(rec.current_steps, {feature.name,  scenario_name}, nil)
    end

  end

  @impl true
  def init_formatter() do
    {:ok, %CliFormatterState{}}
  end

  @impl true
  def feature_start(state, {_, feature}) do
    IO.puts(["Feature: ", Map.get(feature, :name, ""), "\n"])
    state
  end

  @impl true
  def feature_end(state, {_, feature}) do
    case CliFormatterState.incomplete_scenarios(state, feature) do
      nil -> :ok
      a -> Enum.each(a, fn(a) ->
        {_, {step_type, step_text,step_meta}} = CliFormatterState.step_for_scenario(state, feature, a)
        format_step_error(step_type, step_text, step_meta, nil)
      end)
    end
    state
    |> CliFormatterState.pop_feature(feature)
  end

  @impl true
  def scenario_start(state, {_, {feature, scenario}}) do
    IO.puts(["  Scenario: ", scenario.name])
    state
    |> CliFormatterState.enqueue_scenario(feature, scenario)
  end

  @impl true
  def scenario_end(state, {_, {feature, scenario}}) do
    case CliFormatterState.incomplete_step(state, feature, scenario) do
      nil -> :ok
      {_, {step_type, step_text,step_meta}} -> format_step_error(step_type, step_text, step_meta, nil)
    end
    state
    |> CliFormatterState.pop_scenario(feature,scenario)
  end

  @impl true
  def scenario_error(state, {_, {feature, scenario, error}}) do
    case CliFormatterState.incomplete_step(state, feature, scenario) do
      nil -> :ok
      {_, {step_type, step_text,step_meta}} ->
        format_step_error(step_type, step_text, step_meta, error)
    end
    state
    |> CliFormatterState.pop_scenario(feature,scenario)
  end

  @impl true
  def step_start(state, {_, {feature, scenario, step_type, step_text, step_index, step_meta}}) do
    state
    |> CliFormatterState.enqueue_step(feature, scenario, {step_type, step_text, step_meta}, step_index)
  end

  @impl true
  def step_end(state, {_, {feature, scenario, step_type, step_text, _step_index}}) do
    IO.puts(["    ", IO.ANSI.green(), step_type, " ", step_text, IO.ANSI.default_color()])
    state
    |> CliFormatterState.pop_step(feature, scenario)
  end

  defp format_step_error(step_type, step_text,step_meta, nil) do
    print_step_error_and_meta(step_type, step_text, step_meta)
  end

  defp format_step_error(step_type, step_text,step_meta, error) do
    print_step_error_and_meta(step_type, step_text, step_meta)
    case error do
      %ExUnit.AssertionError{} ->
        print_indented_error(ExUnit.Formatter.format_assertion_error(error))
      a ->
        print_indented_error(Exception.format(:error, a))
    end
  end

  defp print_step_error_and_meta(step_type, step_text,step_meta) do
    IO.puts(["    ", IO.ANSI.red(), step_type, " ", step_text, IO.ANSI.default_color()])
    IO.puts([
      "      ",
      IO.ANSI.red(),
      step_meta.file,
      ":",
      Integer.to_string(step_meta.line),
      IO.ANSI.default_color()
    ])
  end

  defp print_indented_error(error_lines) do
    {:ok, string_io} = StringIO.open(error_lines)
    stream = IO.stream(string_io, :line)
    errors_lines = (stream
    |> Enum.map(fn(data) ->
      "      " <> data
    end))
    StringIO.close(string_io)
    IO.write([
      IO.ANSI.red(),
      errors_lines,
      IO.ANSI.default_color()
    ])
  end
end
