require "json"

module MCProtocol
  # String schema definition for elicitation form validation.
  # Supports format validation for date, date-time, email, uri.
  class StringSchema
    include JSON::Serializable

    # The schema type, always "string"
    @[JSON::Field(key: "type")]
    getter type : String = "string"

    # Optional description of the field
    @[JSON::Field(key: "description")]
    getter description : String?

    # Optional format validation: date, date-time, email, uri
    @[JSON::Field(key: "format")]
    getter format : String?

    # Optional minimum length constraint
    @[JSON::Field(key: "minLength")]
    getter min_length : Int32?

    # Optional maximum length constraint
    @[JSON::Field(key: "maxLength")]
    getter max_length : Int32?

    # Optional title for UI display
    @[JSON::Field(key: "title")]
    getter title : String?

    def initialize(@description : String? = nil, @format : String? = nil, @min_length : Int32? = nil, @max_length : Int32? = nil, @title : String? = nil)
      if @format && !["date", "date-time", "email", "uri"].includes?(@format)
        raise ArgumentError.new("StringSchema format must be one of: date, date-time, email, uri")
      end
    end
  end
end 