module MCProtocol
  # Describes a message returned as part of a prompt.
  #
  # This is similar to `SamplingMessage`, but also supports the embedding of
  # resources from the MCP server.
  class PromptMessage
    include JSON::Serializable
    getter content : ContentBlock
    getter role : Role

    def initialize(@content : ContentBlock, @role : Role)
    end
  end
end
