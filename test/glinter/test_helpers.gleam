import glance
import gleam/list
import glinter/rule.{type LintResult, LintResult}

/// Parse source and lint with a new-style Rule, returning LintResults.
pub fn lint_string_rule(source: String, r: rule.Rule) -> List(LintResult) {
  let assert Ok(module) = glance.module(source)
  rule.run_on_module(rule: r, module: module, source: source)
  |> list.map(fn(err) {
    LintResult(
      rule: rule.name(r),
      severity: rule.default_severity(r),
      file: "test.gleam",
      location: rule.error_location(err),
      message: rule.error_message(err),
      details: rule.error_details(err),
    )
  })
}
