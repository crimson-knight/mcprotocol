module MCProtocol
  # The server's response to a tool call.
  #
  # Any errors that originate from the tool SHOULD be reported inside the result
  # object, with `isError` set to true, _not_ as an MCP protocol-level error
  # response. Otherwise, the LLM would not be able to see that an error occurred
  # and self-correct.
  #
  # However, any errors in _finding_ the tool, an error indicating that the
  # server does not support tool calls, or any other exceptional conditions,
  # should be reported as an MCP error response.
  class CallToolResult
    include JSON::Serializable
    # This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
    getter _meta : JSON::Any?
    
    # Content provided by the tool. This should contain ContentBlock items.
    getter content : Array(ContentBlock)
    
    # Whether the tool call ended in an error.
    #
    # If not set, this is assumed to be false (the call was successful).
    getter isError : Bool?
    
    # Optional structured JSON data returned by the tool, conforming to the tool's outputSchema if defined.
    # This allows tools to return data in a machine-readable format alongside human-readable content.
    getter structuredContent : JSON::Any?

    def initialize(@content : Array(ContentBlock), @_meta : JSON::Any? = nil, @isError : Bool? = nil, @structuredContent : JSON::Any? = nil)
    end
  end
end
