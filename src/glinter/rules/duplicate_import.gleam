import glance
import gleam/set
import glinter/rule

pub fn rule() -> rule.Rule {
  rule.new_with_context(name: "duplicate_import", initial: set.new())
  |> rule.with_import_visitor(visitor: check_import)
  |> rule.to_module_rule()
}

fn check_import(
  definition: glance.Definition(glance.Import),
  seen: set.Set(String),
) -> #(List(rule.RuleError), set.Set(String)) {
  let module_name = definition.definition.module
  case set.contains(seen, module_name) {
    True -> #(
      [
        rule.error(
          message: "Module '" <> module_name <> "' is imported more than once",
          details: "Remove the duplicate import statement.",
          location: definition.definition.location,
        ),
      ],
      seen,
    )
    False -> #([], set.insert(seen, module_name))
  }
}
