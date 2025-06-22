module MCProtocol
  # A JSON Schema object defining the expected parameters for the tool.
  class ToolInputSchema
    include JSON::Serializable
    getter properties : JSON::Any?
    getter required : Array(String)?
    getter type : String = "object"

    def initialize(@properties : JSON::Any? = nil, @required : Array(String)? = nil, @type : String = "object")
    end
  end

  # Definition for a tool the client can call.
  class Tool
    include JSON::Serializable
    
    # This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
    @[JSON::Field(key: "_meta", description: "See [specification/2025-06-18/basic/index#general-fields] for notes on _meta usage.")]
    getter meta : Hash(String, JSON::Any)?
    
    # A human-readable description of the tool.
    getter description : String?
    # A JSON Schema object defining the expected parameters for the tool.
    getter inputSchema : ToolInputSchema
    # Intended for programmatic or logical use, but used as a display name in past specs or fallback (if title isn't present).
    getter name : String
    
    # A JSON Schema object defining the expected output format for the tool.
    # This allows tools to specify structured output requirements.
    getter outputSchema : JSON::Any?
    
    # Intended for UI and end-user contexts — optimized to be human-readable and easily understood.
    # If not provided, the name field serves as the fallback for UI display.
    getter title : String?

    def initialize(@inputSchema : ToolInputSchema, @name : String, @description : String? = nil, @outputSchema : JSON::Any? = nil, @title : String? = nil, @meta : Hash(String, JSON::Any)? = nil)
    end
  end
end
