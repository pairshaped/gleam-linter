import glance
import gleam/option.{None, Some}
import glinter/rule.{type Rule, Error, LintResult, Rule}

pub fn rule() -> Rule {
  Rule(
    name: "avoid_panic",
    default_severity: Error,
    check_expression: Some(check),
    check_statement: None,
    check_function: None,
    check_module: None,
  )
}

fn check(expr: glance.Expression) -> List(rule.LintResult) {
  case expr {
    glance.Panic(location, _) -> [
      LintResult(
        rule: "avoid_panic",
        severity: Error,
        file: "",
        location: location,
        message: "Use Result types instead of panic",
      ),
    ]
    _ -> []
  }
}
