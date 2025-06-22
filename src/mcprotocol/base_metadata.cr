require "json"

module MCProtocol
  # Base interface for metadata with name (identifier) and title (display name) properties.
  # This provides consistent naming patterns across all MCP types.
  class BaseMetadata
    include JSON::Serializable

    # Intended for programmatic or logical use, but used as a display name in past specs or fallback (if title isn't present).
    @[JSON::Field(key: "name", description: "Intended for programmatic or logical use, but used as a display name in past specs or fallback (if title isn't present).")]
    getter name : String

    # Intended for UI and end-user contexts — optimized to be human-readable and easily understood,
    # even by those unfamiliar with domain-specific terminology.
    #
    # If not provided, the name should be used for display (except for Tool,
    # where `annotations.title` should be given precedence over using `name`,
    # if present).
    @[JSON::Field(key: "title", description: "Intended for UI and end-user contexts — optimized to be human-readable and easily understood, even by those unfamiliar with domain-specific terminology.")]
    getter title : String?

    def initialize(@name : String, @title : String? = nil)
    end
  end
end 