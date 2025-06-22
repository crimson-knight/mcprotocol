module MCProtocol
  class BlobResourceContents
    include JSON::Serializable
    
    # This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
    @[JSON::Field(key: "_meta", description: "See [specification/2025-06-18/basic/index#general-fields] for notes on _meta usage.")]
    getter meta : Hash(String, JSON::Any)?
    
    # A base64-encoded string representing the binary data of the item.
    getter blob : String
    # The MIME type of this resource, if known.
    getter mimeType : String?
    # The URI of this resource.
    @[JSON::Field(converter: MCProtocol::URIConverter)]
    getter uri : URI

    def initialize(@blob : String, @uri : URI, @mimeType : String? = nil, @meta : Hash(String, JSON::Any)? = nil)
    end
  end
end
