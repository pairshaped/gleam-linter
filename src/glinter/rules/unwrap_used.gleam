import glance
import gleam/option.{None, Some}
import glinter/rule.{type Rule, LintResult, Rule, Warning}

pub fn rule() -> Rule {
  Rule(
    name: "unwrap_used",
    default_severity: Warning,
    check_expression: Some(check),
    check_statement: None,
    check_function: None,
    check_module: None,
  )
}

fn check(expr: glance.Expression) -> List(rule.LintResult) {
  case expr {
    glance.Call(
      location,
      glance.FieldAccess(_, glance.Variable(_, module), label),
      _,
    ) ->
      case module {
        "result" | "option" ->
          case label {
            "unwrap" | "lazy_unwrap" -> [
              LintResult(
                rule: "unwrap_used",
                severity: Warning,
                file: "",
                location: location,
                message: "Avoid "
                  <> module
                  <> "."
                  <> label
                  <> " — use a case expression to handle all variants",
              ),
            ]
            _ -> []
          }
        _ -> []
      }
    _ -> []
  }
}
