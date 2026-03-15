import glance
import gleam/int
import gleam/list
import glinter/analysis
import glinter/rule.{type Rule, Rule, Off, RuleResult}

const threshold = 100

pub fn rule() -> Rule {
  Rule(name: "module_complexity", default_severity: Off, needs_collect: False, check: check)
}

fn check(data: rule.ModuleData, _source: String) -> List(rule.RuleResult) {
  let count =
    data.module.functions
    |> list.fold(0, fn(acc, def) {
      acc + analysis.count_branches(def.definition.body)
    })
  case count > threshold {
    True -> [
      RuleResult(
        rule: "module_complexity",
        location: glance.Span(0, 0),
        message: "Module has a complexity of "
          <> int.to_string(count)
          <> " — consider splitting into smaller modules",
      ),
    ]
    False -> []
  }
}
