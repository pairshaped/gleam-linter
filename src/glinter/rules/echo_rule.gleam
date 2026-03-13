import glance
import gleam/option.{None, Some}
import glinter/rule.{type Rule, LintResult, Rule, Warning}

pub fn rule() -> Rule {
  Rule(
    name: "echo",
    default_severity: Warning,
    check_expression: Some(check),
    check_statement: None,
    check_function: None,
    check_module: None,
  )
}

fn check(expr: glance.Expression) -> List(rule.LintResult) {
  case expr {
    glance.Echo(location, _, _) -> [
      LintResult(
        rule: "echo",
        severity: Warning,
        file: "",
        location: location,
        message: "Remove debug echo statement",
      ),
    ]
    _ -> []
  }
}
