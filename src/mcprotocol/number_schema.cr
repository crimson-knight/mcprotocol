require "json"

module MCProtocol
  # Number schema definition for elicitation form validation.
  # Supports both integer and number types.
  class NumberSchema
    include JSON::Serializable

    # The schema type, can be "integer" or "number"
    @[JSON::Field(key: "type")]
    getter type : String

    # Optional description of the field
    @[JSON::Field(key: "description")]
    getter description : String?

    # Optional minimum value constraint
    @[JSON::Field(key: "minimum")]
    getter minimum : Int32?

    # Optional maximum value constraint
    @[JSON::Field(key: "maximum")]
    getter maximum : Int32?

    # Optional title for UI display
    @[JSON::Field(key: "title")]
    getter title : String?

    def initialize(@type : String, @description : String? = nil, @minimum : Int32? = nil, @maximum : Int32? = nil, @title : String? = nil)
      unless ["integer", "number"].includes?(@type)
        raise ArgumentError.new("NumberSchema type must be 'integer' or 'number'")
      end
    end
  end
end 