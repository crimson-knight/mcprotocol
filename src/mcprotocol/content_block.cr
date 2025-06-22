require "./text_content"
require "./image_content"
require "./resource_link"
require "./embedded_resource"

module MCProtocol
  # Union type for all content blocks in the MCP protocol.
  # Used in prompt messages, tool results, and other content contexts.
  # Note: AudioContent will be added when implemented
  alias ContentBlock = TextContent | ImageContent | ResourceLink | EmbeddedResource
end 