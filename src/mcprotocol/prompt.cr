module MCProtocol
  # A prompt or prompt template that the server offers.
  class Prompt
    include JSON::Serializable
    
    # This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
    @[JSON::Field(key: "_meta", description: "See [specification/2025-06-18/basic/index#general-fields] for notes on _meta usage.")]
    getter meta : Hash(String, JSON::Any)?
    
    # A list of arguments to use for templating the prompt.
    getter arguments : Array(PromptArgument)?
    # An optional description of what this prompt provides
    getter description : String?
    # Intended for programmatic or logical use, but used as a display name in past specs or fallback (if title isn't present).
    getter name : String
    
    # Intended for UI and end-user contexts — optimized to be human-readable and easily understood.
    # If not provided, the name field serves as the fallback for UI display.
    getter title : String?

    def initialize(@name : String, @arguments : Array(PromptArgument)? = nil, @description : String? = nil, @title : String? = nil, @meta : Hash(String, JSON::Any)? = nil)
    end
  end
end
