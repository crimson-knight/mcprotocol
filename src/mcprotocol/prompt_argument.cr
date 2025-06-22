module MCProtocol
  # Describes an argument that a prompt can accept.
  class PromptArgument
    include JSON::Serializable
    # A human-readable description of the argument.
    getter description : String?
    
    # Intended for programmatic or logical use, but used as a display name in past specs or fallback (if title isn't present).
    getter name : String
    
    # Whether this argument must be provided.
    getter required : Bool?
    
    # Intended for UI and end-user contexts — optimized to be human-readable and easily understood.
    # If not provided, the name field serves as the fallback for UI display.
    getter title : String?

    def initialize(@name : String, @description : String? = nil, @required : Bool? = nil, @title : String? = nil)
    end
  end
end
