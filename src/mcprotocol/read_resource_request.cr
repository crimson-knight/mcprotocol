module MCProtocol
  class ReadResourceRequestParams
    include JSON::Serializable
    # The URI of the resource to read. The URI can use any protocol; it is up to the server how to interpret it.
    @[JSON::Field(converter: MCProtocol::URIConverter)]
    getter uri : URI

    def initialize(@uri : URI)
    end
  end

  # Sent from the client to the server, to read a specific resource URI.
  class ReadResourceRequest
    include JSON::Serializable
    getter method : String = "resources/read"
    getter params : ReadResourceRequestParams

    def initialize(@params : ReadResourceRequestParams)
    end
  end
end
