import glance
import gleam/option.{None, Some}
import glinter/rule.{type Rule, LintResult, Rule, Warning}

pub fn rule() -> Rule {
  Rule(
    name: "assert_ok_pattern",
    default_severity: Warning,
    check_expression: None,
    check_statement: Some(check),
    check_function: None,
    check_module: None,
  )
}

fn check(stmt: glance.Statement) -> List(rule.LintResult) {
  case stmt {
    glance.Assignment(location: location, kind: glance.LetAssert(_), ..) -> [
      LintResult(
        rule: "assert_ok_pattern",
        severity: Warning,
        file: "",
        location: location,
        message: "let assert crashes on mismatch — handle the error with a case expression",
      ),
    ]
    _ -> []
  }
}
