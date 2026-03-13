import glance
import gleam/option.{None, Some}
import glinter/rule.{type Rule, LintResult, Rule, Warning}

pub fn rule() -> Rule {
  Rule(
    name: "redundant_case",
    default_severity: Warning,
    check_expression: Some(check),
    check_statement: None,
    check_function: None,
    check_module: None,
  )
}

fn check(expr: glance.Expression) -> List(rule.LintResult) {
  case expr {
    glance.Case(location, _, clauses) ->
      case clauses {
        [clause] ->
          case clause.guard {
            None -> [
              LintResult(
                rule: "redundant_case",
                severity: Warning,
                file: "",
                location: location,
                message: "Case expression has only one branch — use a let binding instead",
              ),
            ]
            Some(_) -> []
          }
        _ -> []
      }
    _ -> []
  }
}
