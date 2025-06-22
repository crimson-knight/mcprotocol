module MCProtocol
  # Describes the name and version of an MCP implementation.
  class Implementation
    include JSON::Serializable
    
    # Intended for programmatic or logical use, but used as a display name in past specs or fallback (if title isn't present).
    getter name : String
    
    # Intended for UI and end-user contexts — optimized to be human-readable and easily understood.
    # If not provided, the name field serves as the fallback for UI display.
    getter title : String?
    
    getter version : String

    def initialize(@name : String, @version : String, @title : String? = nil)
    end
  end
end
