import glance
import gleam/list
import gleam/option.{None, Some}
import glinter/rule

pub fn rule() -> rule.Rule {
  rule.new(name: "missing_type_annotation")
  |> rule.with_simple_function_visitor(visitor: check_function)
  |> rule.to_module_rule()
}

fn check_function(
  definition: glance.Definition(glance.Function),
  span: glance.Span,
) -> List(rule.RuleError) {
  let function = definition.definition
  let return_result = case function.return {
    None -> [
      rule.error(
        message: "Function '"
          <> function.name
          <> "' is missing a return type annotation",
        details: "Add a return type annotation to improve readability and catch type errors early.",
        location: span,
      ),
    ]
    Some(_) -> []
  }

  let param_results =
    function.parameters
    |> list.filter_map(fn(param) {
      case param.type_ {
        None -> {
          let name = case param.name {
            glance.Named(n) -> n
            glance.Discarded(n) -> "_" <> n
          }
          Ok(rule.error(
            message: "Function '"
              <> function.name
              <> "' has untyped parameter '"
              <> name
              <> "'",
            details: "Add a type annotation to this parameter.",
            location: span,
          ))
        }
        Some(_) -> Error(Nil)
      }
    })

  list.append(return_result, param_results)
}
