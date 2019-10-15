defmodule Cabbage.Output.StatusEvent do
  @type status_event :: suite_start |
                        suite_end |
                        feature_start |
                        feature_end |
                        scenario_start |
                        scenario_end |
                        step_start |
                        step_end

  @type suite_start :: {:suite_start, any()}
  @type suite_end :: {:suite_end, any()}
  @type feature_start :: {:feature_start, Gherkin.Elements.Feature.t}
  @type feature_end :: {:feature_end, Gherkin.Elements.Feature.t}
  @type scenario_start :: {:scenario_start, {Gherkin.Elements.Feature.t, Gherkin.Elements.Scenario.t}}
  @type scenario_end :: {:scenario_end, {Gherkin.Elements.Feature.t, Gherkin.Elements.Scenario.t}}
  @type step_start :: {
    :step_start,
    {
      Gherkin.Elements.Feature.t,
      Gherkin.Elements.Scenario.t,
      any,
      any,
      integer
    }
  }
  @type step_end :: {
    :step_end,
    {
      Gherkin.Elements.Feature.t,
      Gherkin.Elements.Scenario.t,
      any,
      any,
      integer
    }
  }
end
