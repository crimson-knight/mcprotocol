require "json"

module MCProtocol
  # Enum schema definition for elicitation form validation.
  # Provides a list of allowable string values with optional display names.
  class EnumSchema
    include JSON::Serializable

    # The schema type, always "string" for enums
    @[JSON::Field(key: "type")]
    getter type : String = "string"

    # Required array of enumerated values
    @[JSON::Field(key: "enum")]
    getter enum : Array(String)

    # Optional array of human-readable names corresponding to enum values
    @[JSON::Field(key: "enumNames")]
    getter enum_names : Array(String)?

    # Optional description of the field
    @[JSON::Field(key: "description")]
    getter description : String?

    # Optional title for UI display
    @[JSON::Field(key: "title")]
    getter title : String?

    def initialize(@enum : Array(String), @enum_names : Array(String)? = nil, @description : String? = nil, @title : String? = nil)
      if @enum_names && @enum_names.not_nil!.size != @enum.size
        raise ArgumentError.new("EnumSchema enumNames array must match the size of enum array")
      end
    end
  end
end 