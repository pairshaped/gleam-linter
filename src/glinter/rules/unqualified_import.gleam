import glance
import gleam/list
import gleam/option.{None, Some}
import glinter/rule.{type Rule, LintResult, Rule, Warning}

pub fn rule() -> Rule {
  Rule(
    name: "unqualified_import",
    default_severity: Warning,
    check_expression: None,
    check_statement: None,
    check_function: None,
    check_module: Some(check),
  )
}

fn check(module: glance.Module) -> List(rule.LintResult) {
  module.imports
  |> list.flat_map(fn(def) {
    let glance.Definition(_, import_) = def
    import_.unqualified_values
    |> list.map(fn(uq) {
      LintResult(
        rule: "unqualified_import",
        severity: Warning,
        file: "",
        location: import_.location,
        message: "Value '"
          <> uq.name
          <> "' is imported unqualified from '"
          <> import_.module
          <> "', use qualified access instead",
      )
    })
  })
}
