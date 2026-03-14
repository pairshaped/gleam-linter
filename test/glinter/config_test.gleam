import gleam/dict
import gleam/option.{None, Some}
import gleeunit/should
import glinter/config

pub fn parse_empty_config_test() {
  let assert Ok(c) = config.parse("")
  dict.size(c.rules) |> should.equal(0)
  dict.size(c.ignore) |> should.equal(0)
}

pub fn parse_rules_section_test() {
  let toml =
    "[tools.glinter.rules]
avoid_panic = \"error\"
echo = \"off\"
"
  let assert Ok(c) = config.parse(toml)
  dict.get(c.rules, "avoid_panic")
  |> should.equal(Ok(Some(config.SeverityError)))
  dict.get(c.rules, "echo") |> should.equal(Ok(None))
}

pub fn parse_warning_severity_test() {
  let toml =
    "[tools.glinter.rules]
echo = \"warning\"
"
  let assert Ok(c) = config.parse(toml)
  dict.get(c.rules, "echo")
  |> should.equal(Ok(Some(config.SeverityWarning)))
}

pub fn parse_ignore_section_test() {
  let toml =
    "[tools.glinter.ignore]
\"test/**/*.gleam\" = [\"avoid_panic\", \"echo\"]
"
  let assert Ok(c) = config.parse(toml)
  dict.get(c.ignore, "test/**/*.gleam")
  |> should.equal(Ok(["avoid_panic", "echo"]))
}

pub fn parse_gleam_toml_with_other_sections_test() {
  let toml =
    "name = \"myapp\"
version = \"1.0.0\"

[dependencies]
gleam_stdlib = \">= 0.44.0\"

[tools.glinter.rules]
echo = \"error\"
"
  let assert Ok(c) = config.parse(toml)
  dict.get(c.rules, "echo")
  |> should.equal(Ok(Some(config.SeverityError)))
}

pub fn default_config_test() {
  let c = config.default()
  dict.size(c.rules) |> should.equal(0)
  dict.size(c.ignore) |> should.equal(0)
}
