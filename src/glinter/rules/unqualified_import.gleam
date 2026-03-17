import glance
import gleam/list
import gleam/string
import glinter/rule

pub fn rule() -> rule.Rule {
  rule.new(name: "unqualified_import")
  |> rule.with_simple_import_visitor(visitor: check_import)
  |> rule.to_module_rule()
}

fn check_import(
  definition: glance.Definition(glance.Import),
) -> List(rule.RuleError) {
  let import_ = definition.definition
  import_.unqualified_values
  |> list.filter_map(fn(uq) {
    // Allow PascalCase constructors (Some, None, Ok, Error, etc.)
    // Only flag snake_case functions and constants
    case is_lowercase_start(uq.name) {
      True ->
        Ok(rule.error(
          message: "Function '"
            <> uq.name
            <> "' is imported unqualified from '"
            <> import_.module
            <> "', use qualified access instead",
          details: "Use qualified access (e.g., module.function) for better readability.",
          location: import_.location,
        ))
      False -> Error(Nil)
    }
  })
}

fn is_lowercase_start(name: String) -> Bool {
  case string.first(name) {
    Ok(c) -> c == string.lowercase(c)
    Error(_) -> False
  }
}
