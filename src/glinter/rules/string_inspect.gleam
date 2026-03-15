import glance
import gleam/list
import glinter/rule.{type Rule, Rule, RuleResult, Warning}

pub fn rule() -> Rule {
  Rule(name: "string_inspect", default_severity: Warning, needs_collect: True, check: check)
}

fn check(data: rule.ModuleData, _source: String) -> List(rule.RuleResult) {
  data.expressions |> list.flat_map(check_expression)
}

fn check_expression(expr: glance.Expression) -> List(rule.RuleResult) {
  case expr {
    glance.FieldAccess(location, glance.Variable(_, "string"), "inspect") -> [
      RuleResult(
        rule: "string_inspect",
        location: location,
        message: "Use of 'string.inspect' is discouraged outside of debugging",
      ),
    ]
    _ -> []
  }
}
