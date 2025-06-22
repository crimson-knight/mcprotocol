module MCProtocol
  class ResourceAnnotations
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

  # A known resource that the server is capable of reading.
  class Resource
    include JSON::Serializable
    
    # This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
    @[JSON::Field(key: "_meta", description: "See [specification/2025-06-18/basic/index#general-fields] for notes on _meta usage.")]
    getter meta : Hash(String, JSON::Any)?
    
    getter annotations : ResourceAnnotations?
    # A description of what this resource represents.
    #
    # This can be used by clients to improve the LLM's understanding of available resources. It can be thought of like a "hint" to the model.
    getter description : String?
    # The MIME type of this resource, if known.
    getter mimeType : String?
    # Intended for programmatic or logical use, but used as a display name in past specs or fallback (if title isn't present).
    getter name : String
    
    # Intended for UI and end-user contexts — optimized to be human-readable and easily understood.
    # If not provided, the name field serves as the fallback for UI display.
    getter title : String?
    # The size of the raw resource content, in bytes (i.e., before base64 encoding or any tokenization), if known.
    #
    # This can be used by Hosts to display file sizes and estimate context window usage.
    getter size : Int64?
    # The URI of this resource.
    @[JSON::Field(converter: MCProtocol::URIConverter)]
    getter uri : URI

    def initialize(@name : String, @uri : URI, @annotations : ResourceAnnotations? = nil, @description : String? = nil, @mimeType : String? = nil, @size : Int64? = nil, @title : String? = nil, @meta : Hash(String, JSON::Any)? = nil)
    end
  end
end
