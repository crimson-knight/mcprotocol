module MCProtocol
  class TextContentAnnotations
    include JSON::Serializable
    # Describes who the intended customer of this object or data is.
    #
    # It can include multiple entries to indicate content useful for multiple audiences (e.g., `["user", "assistant"]`).
    getter audience : Array(Role)?
    # Describes how important this data is for operating the server.
    #
    # A value of 1 means "most important," and indicates that the data is
    # effectively required, while 0 means "least important," and indicates that
    # the data is entirely optional.
    getter priority : Float64?

    def initialize(@audience : Array(Role)? = nil, @priority : Float64? = nil)
    end
  end

  # Text provided to or from an LLM.
  class TextContent
    include JSON::Serializable
    
    # This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
    @[JSON::Field(key: "_meta", description: "See [specification/2025-06-18/basic/index#general-fields] for notes on _meta usage.")]
    getter meta : Hash(String, JSON::Any)?
    
    getter annotations : TextContentAnnotations?
    # The text content of the message.
    getter text : String
    getter type : String = "text"

    def initialize(@text : String, @annotations : TextContentAnnotations? = nil, @type : String = "text", @meta : Hash(String, JSON::Any)? = nil)
    end
  end
end
