module MCProtocol
  # The argument's information
  class CompleteRequestParamsArgument
    include JSON::Serializable
    # The name of the argument
    getter name : String
    # The value of the argument to use for completion matching.
    getter value : String

    def initialize(@name : String, @value : String)
    end
  end

  class CompleteRequestParams
    include JSON::Serializable
    # The argument's information
    getter argument : CompleteRequestParamsArgument
    
    # Additional context to help with completion
    getter context : Hash(String, JSON::Any)?
    
    # Reference to the prompt or resource template for completion
    getter ref : PromptReference | ResourceTemplateReference

    def initialize(@argument : CompleteRequestParamsArgument, @ref : PromptReference | ResourceTemplateReference, @context : Hash(String, JSON::Any)? = nil)
    end
  end

  # A request from the client to the server, to ask for completion options.
  class CompleteRequest
    include JSON::Serializable
    getter method : String = "completion/complete"
    getter params : CompleteRequestParams

    def initialize(@params : CompleteRequestParams)
    end
  end
end
