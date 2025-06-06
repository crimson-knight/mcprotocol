module MCProtocol
  class CallToolRequestParams
    include JSON::Serializable
    getter arguments : JSON::Any?
    getter name : String

    def initialize(@name : String, @arguments : JSON::Any? = nil)
    end
  end

  # Used by the client to invoke a tool provided by the server.
  class CallToolRequest
    include JSON::Serializable
    getter method : String = "tools/call"
    getter params : CallToolRequestParams

    def initialize(@params : CallToolRequestParams)
    end
  end
end
