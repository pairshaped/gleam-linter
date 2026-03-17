import glance
import gleam/list
import gleam/option.{None}
import glinter/rule

pub fn rule() -> rule.Rule {
  rule.new(name: "label_possible")
  |> rule.with_simple_function_visitor(visitor: check_function)
  |> rule.to_module_rule()
}

fn check_function(
  function: glance.Function,
  span: glance.Span,
) -> List(rule.RuleError) {
  let params = function.parameters
  // Skip functions with fewer than 2 params, or any unlabelled discard param
  // (you can't fully label a function that has an unlabelled discard)
  let has_unlabelled_discard =
    list.any(params, fn(param) {
      param.label == None
      && case param.name {
        glance.Discarded(_) -> True
        glance.Named(_) -> False
      }
    })
  case list.length(params) >= 2 && !has_unlabelled_discard {
    False -> []
    True ->
      params
      |> list.filter(fn(param) { param.label == None })
      |> list.map(fn(param) {
        let assert glance.Named(name) = param.name
        rule.error(
          message: "Parameter '"
            <> name
            <> "' could benefit from a label for clarity at call sites",
          details: "Labelled arguments make call sites self-documenting with zero performance cost.",
          location: span,
        )
      })
  }
}
