import glance
import gleam/int
import gleam/option.{None, Some}
import glinter/analysis
import glinter/rule.{type Rule, LintResult, Rule, Warning}

const threshold = 10

pub fn rule() -> Rule {
  Rule(
    name: "function_complexity",
    default_severity: Warning,
    check_expression: None,
    check_statement: None,
    check_function: Some(check),
    check_module: None,
  )
}

fn check(func: glance.Function) -> List(rule.LintResult) {
  let count = analysis.count_branches(func.body)
  case count > threshold {
    True -> [
      LintResult(
        rule: "function_complexity",
        severity: Warning,
        file: "",
        location: func.location,
        message: "Function '"
          <> func.name
          <> "' has a complexity of "
          <> int.to_string(count)
          <> " — consider splitting into smaller functions",
      ),
    ]
    False -> []
  }
}
