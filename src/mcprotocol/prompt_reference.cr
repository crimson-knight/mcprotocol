module MCProtocol
  # Identifies a prompt.
  class PromptReference
    include JSON::Serializable
    
    # Intended for programmatic or logical use, but used as a display name in past specs or fallback (if title isn't present).
    getter name : String
    
    # Intended for UI and end-user contexts — optimized to be human-readable and easily understood.
    # If not provided, the name field serves as the fallback for UI display.
    getter title : String?
    
    getter type : String = "ref/prompt"

    def initialize(@name : String, @type : String = "ref/prompt", @title : String? = nil)
    end
  end
end
