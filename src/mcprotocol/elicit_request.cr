require "json"
require "./primitive_schema_definition"

module MCProtocol
  # Parameters for an elicitation request
  class ElicitRequestParams
    include JSON::Serializable

    # The message to present to the user
    @[JSON::Field(key: "message")]
    getter message : String

    # A restricted subset of JSON Schema - only top-level properties are allowed, without nesting
    @[JSON::Field(key: "requestedSchema")]
    getter requested_schema : ElicitRequestSchema

    def initialize(@message : String, @requested_schema : ElicitRequestSchema)
    end
  end

  # The restricted JSON Schema for elicitation requests
  class ElicitRequestSchema
    include JSON::Serializable

    # The schema type, always "object"
    @[JSON::Field(key: "type")]
    getter type : String = "object"

    # Properties mapping field names to their schema definitions
    @[JSON::Field(key: "properties")]
    getter properties : Hash(String, PrimitiveSchemaDefinition)

    # Optional array of required field names
    @[JSON::Field(key: "required")]
    getter required : Array(String)?

    def initialize(@properties : Hash(String, PrimitiveSchemaDefinition), @required : Array(String)? = nil)
    end
  end

  # A request from the server to elicit additional information from the user via the client.
  class ElicitRequest
    include JSON::Serializable

    # The method name for elicitation requests
    @[JSON::Field(key: "method")]
    getter method : String = "elicitation/create"

    # The elicitation parameters
    @[JSON::Field(key: "params")]
    getter params : ElicitRequestParams

    def initialize(@params : ElicitRequestParams)
    end
  end
end 