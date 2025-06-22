module MCProtocol
  class AnnotatedAnnotations
    include JSON::Serializable
    # Describes who the intended customer of this object or data is.
    #
    # It can include multiple entries to indicate content useful for multiple audiences (e.g., `["user", "assistant"]`).
    getter audience : Array(Role)?
    
    # When the data was last modified, in ISO 8601 format.
    #
    # Servers can use this to help clients determine whether they should refresh data.
    # Clients should not rely on this field being present or accurate.
    #
    # Example: `"2024-12-05T10:30:00Z"` for December 5, 2024 at 10:30 AM UTC.
    getter lastModified : String?
    
    # Describes how important this data is for operating the server.
    #
    # A value of 1 means "most important," and indicates that the data is
    # effectively required, while 0 means "least important," and indicates that
    # the data is entirely optional.
    getter priority : Float64?

    def initialize(@audience : Array(Role)? = nil, @priority : Float64? = nil, @lastModified : String? = nil)
    end
  end

  # Base for objects that include optional annotations for the client. The client can use annotations to inform how objects are used or displayed
  class Annotated
    include JSON::Serializable
    getter annotations : AnnotatedAnnotations?

    def initialize(@annotations : AnnotatedAnnotations? = nil)
    end
  end
end
