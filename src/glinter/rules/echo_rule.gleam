import glance
import gleam/list
import glinter/rule.{type Rule, Rule, RuleResult, Warning}

pub fn rule() -> Rule {
  Rule(name: "echo", default_severity: Warning, needs_collect: True, check: check)
}

fn check(data: rule.ModuleData, _source: String) -> List(rule.RuleResult) {
  data.expressions |> list.flat_map(check_expression)
}

fn check_expression(expr: glance.Expression) -> List(rule.RuleResult) {
  case expr {
    glance.Echo(location, _, _) -> [
      RuleResult(
        rule: "echo",
        location: location,
        message: "Remove debug echo statement",
      ),
    ]
    _ -> []
  }
}
