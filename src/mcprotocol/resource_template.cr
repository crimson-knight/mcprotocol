module MCProtocol
  class ResourceTemplateAnnotations
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

  # A template description for resources available on the server.
  class ResourceTemplate
    include JSON::Serializable
    
    # This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
    @[JSON::Field(key: "_meta", description: "See [specification/2025-06-18/basic/index#general-fields] for notes on _meta usage.")]
    getter meta : Hash(String, JSON::Any)?
    
    getter annotations : ResourceTemplateAnnotations?
    # A description of what this template is for.
    #
    # This can be used by clients to improve the LLM's understanding of available resources. It can be thought of like a "hint" to the model.
    getter description : String?
    # The MIME type for all resources that match this template. This should only be included if all resources matching this template have the same type.
    getter mimeType : String?
    # Intended for programmatic or logical use, but used as a display name in past specs or fallback (if title isn't present).
    getter name : String
    
    # Intended for UI and end-user contexts — optimized to be human-readable and easily understood.
    # If not provided, the name field serves as the fallback for UI display.
    getter title : String?
    # A URI template (according to RFC 6570) that can be used to construct resource URIs.
    @[JSON::Field(converter: MCProtocol::URIConverter)]
    getter uriTemplate : URI

    def initialize(@name : String, @uriTemplate : URI, @annotations : ResourceTemplateAnnotations? = nil, @description : String? = nil, @mimeType : String? = nil, @title : String? = nil, @meta : Hash(String, JSON::Any)? = nil)
    end
  end
end
