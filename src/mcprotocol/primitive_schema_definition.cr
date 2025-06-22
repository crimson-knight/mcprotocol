require "./boolean_schema"
require "./number_schema"
require "./string_schema"
require "./enum_schema"

module MCProtocol
  # Restricted schema definitions that only allow primitive types
  # without nested objects or arrays.
  # Used by the elicitation system for form validation.
  alias PrimitiveSchemaDefinition = BooleanSchema | NumberSchema | StringSchema | EnumSchema
end 