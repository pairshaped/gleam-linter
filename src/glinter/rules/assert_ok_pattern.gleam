import glance
import gleam/option.{None, Some}
import glinter/rule

type Context {
  Context(current_function: option.Option(String))
}

pub fn rule() -> rule.Rule {
  rule.new_with_context(
    name: "assert_ok_pattern",
    initial: Context(current_function: None),
  )
  |> rule.with_function_visitor(visitor: track_function)
  |> rule.with_statement_visitor(visitor: check_statement)
  |> rule.to_module_rule()
}

fn track_function(
  function: glance.Function,
  _span: glance.Span,
  _context: Context,
) -> #(List(rule.RuleError), Context) {
  #([], Context(current_function: Some(function.name)))
}

fn check_statement(
  statement: glance.Statement,
  context: Context,
) -> #(List(rule.RuleError), Context) {
  case statement, context.current_function {
    glance.Assignment(kind: glance.LetAssert(_), ..), Some("main") ->
      #([], context)
    glance.Assignment(location: location, kind: glance.LetAssert(_), ..), _ -> #(
      [
        rule.error(
          message: "let assert crashes on mismatch — handle the error with a case expression",
          details: "let assert panics when the pattern does not match. Use case to handle all variants safely. let assert is allowed in main() where crash-on-failure is the correct startup behavior.",
          location: location,
        ),
      ],
      context,
    )
    _, _ -> #([], context)
  }
}
