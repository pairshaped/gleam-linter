import glance
import gleam/list
import gleam/option.{None}
import glinter/rule.{type Rule, Rule, RuleResult, Warning}

pub fn rule() -> Rule {
  Rule(name: "label_possible", default_severity: Warning, needs_collect: False, check: check)
}

fn check(data: rule.ModuleData, _source: String) -> List(rule.RuleResult) {
  data.module.functions
  |> list.flat_map(fn(def) { check_function(def.definition) })
}

fn check_function(func: glance.Function) -> List(rule.RuleResult) {
  let params = func.parameters
  case list.length(params) >= 2 {
    False -> []
    True ->
      params
      |> list.filter(fn(param) { param.label == None })
      |> list.map(fn(param) {
        let name = case param.name {
          glance.Named(n) -> n
          glance.Discarded(n) -> "_" <> n
        }
        RuleResult(
          rule: "label_possible",
          location: func.location,
          message: "Parameter '"
            <> name
            <> "' could benefit from a label for clarity at call sites",
        )
      })
  }
}
