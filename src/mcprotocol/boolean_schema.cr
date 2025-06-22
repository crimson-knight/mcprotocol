require "json"

module MCProtocol
  # Boolean schema definition for elicitation form validation.
  class BooleanSchema
    include JSON::Serializable

    # The schema type, always "boolean"
    @[JSON::Field(key: "type")]
    getter type : String = "boolean"

    # Optional default value for the boolean field
    @[JSON::Field(key: "default")]
    getter default : Bool?

    # Optional description of the field
    @[JSON::Field(key: "description")]
    getter description : String?

    # Optional title for UI display
    @[JSON::Field(key: "title")]
    getter title : String?

    def initialize(@default : Bool? = nil, @description : String? = nil, @title : String? = nil)
    end
  end
end 