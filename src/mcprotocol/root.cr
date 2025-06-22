module MCProtocol
  # Represents a root directory or file that the server can operate on.
  class Root
    include JSON::Serializable
    
    # This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
    @[JSON::Field(key: "_meta", description: "See [specification/2025-06-18/basic/index#general-fields] for notes on _meta usage.")]
    getter meta : Hash(String, JSON::Any)?
    
    # An optional name for the root. This can be used to provide a human-readable
    # identifier for the root, which may be useful for display purposes or for
    # referencing the root in other parts of the application.
    getter name : String?
    # The URI identifying the root. This *must* start with file:// for now.
    # This restriction may be relaxed in future versions of the protocol to allow
    # other URI schemes.
    @[JSON::Field(converter: MCProtocol::URIConverter)]
    getter uri : URI

    def initialize(@uri : URI, @name : String? = nil, @meta : Hash(String, JSON::Any)? = nil)
    end
  end
end
