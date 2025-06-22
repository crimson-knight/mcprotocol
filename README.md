# MCProtocol

A Crystal implementation of Anthropic's [Model Context Protocol (MCP)](https://modelcontextprotocol.io/), providing type-safe bindings for building MCP servers and clients with the latest protocol enhancements.

## What is the Model Context Protocol?

The Model Context Protocol (MCP) is an open standard that enables AI applications to securely connect to various data sources and tools. Think of MCP as a "USB-C port for AI" - it provides a standardized way to connect AI models to:

- **Resources**: Files, databases, APIs, and other data sources
- **Tools**: Functions that AI models can execute  
- **Prompts**: Templated interactions and workflows
- **Elicitation**: Structured user input collection through the client

## MCP Protocol Version Support

**Current Implementation: MCP 2025-06-18** ✨

- ✅ **Full MCP 2025-06-18 support** - Latest protocol with all new features
- ✅ **Backward compatibility** - Graceful handling of MCP 2025-03-26 clients  
- ✅ **Protocol version negotiation** - Automatic feature detection and compatibility
- ✅ **Zero breaking changes** - Existing 2025-03-26 code continues to work

## ✨ New Features in 2025-06-18

### 🔄 **Elicitation System**
Server-to-client structured user input requests with schema validation:
```crystal
# Create a user configuration form
schema = MCProtocol::ElicitRequestSchema.new(
  properties: {
    "email" => MCProtocol::StringSchema.new(
      description: "User's email address",
      title: "Email",
      format: "email"
    ).as(MCProtocol::PrimitiveSchemaDefinition)
  },
  required: ["email"]
)

request = MCProtocol::ElicitRequest.new(
  params: MCProtocol::ElicitRequestParams.new(
    message: "Please configure your user preferences.",
    requested_schema: schema
  )
)
```

### 📋 **Schema Definition System**
Type-safe form validation with primitive schema types:
```crystal
# Boolean schema with default
boolean_schema = MCProtocol::BooleanSchema.new(
  description: "Enable notifications",
  title: "Notifications",
  default: true
)

# Number schema with constraints  
number_schema = MCProtocol::NumberSchema.new(
  "integer",
  description: "Age in years",
  minimum: 13,
  maximum: 120
)

# Enum schema with display names
enum_schema = MCProtocol::EnumSchema.new(
  ["light", "dark", "auto"],
  enum_names: ["Light Theme", "Dark Theme", "Auto-detect"],
  description: "UI theme preference"
)
```

### 🔗 **Enhanced Content Blocks**
New ResourceLink content type for file and resource references:
```crystal
# Link to a file resource
file_link = MCProtocol::ResourceLink.new(
  name: "user_guide",
  uri: "file:///docs/guide.pdf", 
  title: "User Guide",
  description: "Complete user documentation",
  meta: {
    "file_size" => JSON::Any.new("2.4MB"),
    "last_updated" => JSON::Any.new("2025-06-18T10:30:00Z")
  }
)

# Use in prompt messages
prompt = MCProtocol::PromptMessage.new(
  content: file_link.as(MCProtocol::ContentBlock),
  role: MCProtocol::Role::User
)
```

### 🏷️ **Universal Metadata Support**
Enhanced metadata fields across all major types:
```crystal
# Every content type now supports rich metadata
text_content = MCProtocol::TextContent.new(
  "Analysis results are ready for review.",
  meta: {
    "content_type" => JSON::Any.new("analysis_result"),
    "confidence" => JSON::Any.new(0.95),
    "created_at" => JSON::Any.new("2025-06-18T14:30:00Z")
  }
)
```

### ⚙️ **Enhanced Tool Capabilities**
Tools now support structured output schemas:
```crystal
tool = MCProtocol::Tool.new(
  name: "analyze_document",
  title: "Document Analysis",
  description: "Analyze document content and extract insights",
  outputSchema: JSON::Any.new({
    "type" => "object",
    "properties" => {
      "summary" => {"type" => "string"},
      "confidence" => {"type" => "number"}
    }
  })
)
```

## Features

- ✅ **Type-Safe**: Hand-crafted Crystal classes with full type safety
- ✅ **Complete Protocol Support**: Full MCP 2025-06-18 implementation  
- ✅ **Elicitation System**: Structured user input collection
- ✅ **Enhanced Metadata**: Rich metadata support across all types
- ✅ **Schema Validation**: Boolean, Number, String, and Enum schemas
- ✅ **Protocol Versioning**: Backward compatibility with graceful degradation
- ✅ **Server & Client Support**: Build both MCP servers and clients
- ✅ **JSON-RPC 2.0**: Full compliance with the underlying JSON-RPC protocol
- ✅ **SSE Compatible**: Ready for Server-Sent Events implementations
- ✅ **Extensible**: Easy to extend with custom capabilities

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     mcprotocol:
       github: nobodywasishere/mcprotocol
   ```

2. Run `shards install`

## Quick Start

### Basic Usage with Protocol Version Support

```crystal
require "mcprotocol"

# Protocol version negotiation
protocol_version = MCProtocol.negotiate_protocol_version("2025-06-18") # or "2025-03-26"

# Parse MCP messages with version awareness
message_data = %{{"method": "elicitation/create", "params": {...}}}
request = MCProtocol.parse_message(message_data, protocol_version: protocol_version)

# Check feature availability
if MCProtocol.feature_available?("elicitation", protocol_version)
  # Handle elicitation requests
end

# Create MCP objects with enhanced capabilities
capabilities = MCProtocol::ServerCapabilities.new(
  tools: MCProtocol::ServerCapabilitiesTools.new(listChanged: true),
  resources: MCProtocol::ServerCapabilitiesResources.new(subscribe: true),
  elicitation: MCProtocol::ServerCapabilitiesElicitation.new(enabled: true) # New!
)
```

### Building an Enhanced MCP Server

```crystal
require "mcprotocol"
require "json"

class AdvancedMCPServer
  def initialize
    @tools = [
      MCProtocol::Tool.new(
        name: "collect_feedback",
        title: "Collect User Feedback", 
        description: "Collect structured feedback from users",
        outputSchema: JSON::Any.new({
          "type" => "object",
          "properties" => {
            "rating" => {"type" => "integer", "minimum" => 1, "maximum" => 5},
            "comments" => {"type" => "string"}
          }
        })
      )
    ]
  end

  def handle_initialize(request : MCProtocol::InitializeRequest)
    MCProtocol::InitializeResult.new(
      protocolVersion: MCProtocol::PROTOCOL_VERSION, # "2025-06-18"
      capabilities: MCProtocol::ServerCapabilities.new(
        tools: MCProtocol::ServerCapabilitiesTools.new(listChanged: true),
        elicitation: MCProtocol::ServerCapabilitiesElicitation.new(enabled: true)
      ),
      serverInfo: MCProtocol::Implementation.new(
        name: "advanced-server",
        title: "Advanced MCP Server",
        version: "1.0.0"
      )
    )
  end

  def handle_elicitation_request
    # Create feedback collection form
    rating_schema = MCProtocol::NumberSchema.new(
      "integer",
      description: "Rate your experience",
      title: "Rating",
      minimum: 1,
      maximum: 5
    )

    comments_schema = MCProtocol::StringSchema.new(
      description: "Additional comments",
      title: "Comments",
      min_length: 10,
      max_length: 500
    )

    schema = MCProtocol::ElicitRequestSchema.new(
      properties: {
        "rating" => rating_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "comments" => comments_schema.as(MCProtocol::PrimitiveSchemaDefinition)
      },
      required: ["rating"]
    )

    MCProtocol::ElicitRequest.new(
      params: MCProtocol::ElicitRequestParams.new(
        message: "Please rate your experience and provide feedback.",
        requested_schema: schema
      )
    )
  end

  def handle_call_tool(request : MCProtocol::CallToolRequest)
    case request.params.name
    when "collect_feedback"
      # Use elicitation to collect structured feedback
      elicit_request = handle_elicitation_request
      
      # Return with ResourceLink to documentation
      help_link = MCProtocol::ResourceLink.new(
        name: "feedback_help",
        uri: "https://docs.example.com/feedback",
        title: "Feedback Guidelines",
        description: "How to provide effective feedback"
      )

      MCProtocol::CallToolResult.new(
        content: [
          MCProtocol::TextContent.new("Feedback collection initiated."),
          help_link.as(MCProtocol::ContentBlock)
        ],
        structuredContent: JSON::Any.new({
          "elicitation_id" => JSON::Any.new("feedback_001"),
          "status" => JSON::Any.new("pending")
        })
      )
    else
      raise "Unknown tool: #{request.params.name}"
    end
  end
end
```

### Elicitation Workflow Example

```crystal
require "mcprotocol"

# Server creates an elicitation request
def create_user_setup_form
  # Define schema fields
  name_schema = MCProtocol::StringSchema.new(
    description: "Your display name",
    title: "Display Name",
    min_length: 1,
    max_length: 50
  )

  theme_schema = MCProtocol::EnumSchema.new(
    ["light", "dark", "auto"],
    enum_names: ["Light Theme", "Dark Theme", "Auto-detect"],
    description: "Preferred UI theme",
    title: "Theme"
  )

  notifications_schema = MCProtocol::BooleanSchema.new(
    description: "Receive email notifications",
    title: "Email Notifications", 
    default: true
  )

  # Create complete form schema
  schema = MCProtocol::ElicitRequestSchema.new(
    properties: {
      "displayName" => name_schema.as(MCProtocol::PrimitiveSchemaDefinition),
      "theme" => theme_schema.as(MCProtocol::PrimitiveSchemaDefinition), 
      "notifications" => notifications_schema.as(MCProtocol::PrimitiveSchemaDefinition)
    },
    required: ["displayName"]
  )

  # Create elicitation request
  MCProtocol::ElicitRequest.new(
    params: MCProtocol::ElicitRequestParams.new(
      message: "Welcome! Please set up your preferences.",
      requested_schema: schema
    )
  )
end

# Client responds with structured data
def handle_user_response(result : MCProtocol::ElicitResult)
  case result.action
  when "accept"
    if content = result.content
      puts "User configuration:"
      puts "  Display Name: #{content["displayName"]}"
      puts "  Theme: #{content["theme"]}"
      puts "  Notifications: #{content["notifications"]}"
    end
  when "decline"
    puts "User declined setup, using defaults"
  when "cancel"
    puts "User cancelled setup"
  end
end
```

## Protocol Messages

The library includes all MCP protocol message types for both 2025-06-18 and backward compatibility:

### New in 2025-06-18
- `ElicitRequest` - Server requests structured user input
- `ElicitResult` - Client responds with form data or action

### Enhanced in 2025-06-18
- `CallToolResult` - Now supports `structuredContent` field
- `Tool` - Now supports `outputSchema` for structured responses
- All content types - Now support `_meta` metadata fields
- `PromptMessage` - Enhanced content block support

### Standard Protocol Messages
- `InitializeRequest/Result` - Connection and capability negotiation
- `ListToolsRequest/Result` - Tool discovery and listing
- `CallToolRequest/Result` - Tool execution
- `ListResourcesRequest/Result` - Resource discovery
- `ReadResourceRequest/Result` - Resource content access
- `ListPromptsRequest/Result` - Prompt template discovery
- `GetPromptRequest/Result` - Prompt template access

## Available Message Types

The library supports all MCP protocol methods:

```crystal
MCProtocol::METHOD_TYPES.keys
# => ["initialize", "ping", "resources/list", "tools/call", "elicitation/create", ...]

# Check protocol version support
MCProtocol::SUPPORTED_PROTOCOL_VERSIONS
# => ["2025-06-18", "2025-03-26"]
```

## Architecture

```
┌─────────────────┐    JSON-RPC 2.0     ┌─────────────────┐
│   MCP Client    │ ◄─────────────────► │   MCP Server    │
│ (AI Application)│    + Elicitation    │ (Your Service)  │
└─────────────────┘                     └─────────────────┘
        │                                       │
        ▼                                       ▼
┌─────────────────┐                     ┌─────────────────┐
│ MCProtocol      │                     │ MCProtocol      │
│ Crystal Library │                     │ Crystal Library │
│ (2025-06-18)    │                     │ (2025-06-18)    │
└─────────────────┘                     └─────────────────┘
```

## Key Classes

### Core Protocol
- `MCProtocol::ClientRequest` - Union type for all client requests
- `MCProtocol::ServerResult` - Union type for all server responses  
- `MCProtocol::ClientNotification` - Union type for client notifications
- `MCProtocol::ServerNotification` - Union type for server notifications

### New Elicitation System
- `MCProtocol::ElicitRequest` - Server requests for user input
- `MCProtocol::ElicitResult` - Client responses with form data
- `MCProtocol::BooleanSchema` - Boolean field validation
- `MCProtocol::NumberSchema` - Number field validation  
- `MCProtocol::StringSchema` - String field validation
- `MCProtocol::EnumSchema` - Enumerated value validation

### Enhanced Content System
- `MCProtocol::ContentBlock` - Union of all content types
- `MCProtocol::ResourceLink` - Resource reference content type
- `MCProtocol::TextContent` - Text content with metadata
- `MCProtocol::ImageContent` - Image content with metadata

### Capabilities
- `MCProtocol::ClientCapabilities` - What the client supports
- `MCProtocol::ServerCapabilities` - What the server provides
- `MCProtocol::ServerCapabilitiesElicitation` - Elicitation support

### Data Types
- `MCProtocol::Tool` - Enhanced tool definitions with output schemas
- `MCProtocol::Resource` - Resource definitions with metadata
- `MCProtocol::Prompt` - Prompt templates with title support

## Error Handling

```crystal
begin
  # Protocol version negotiation
  version = MCProtocol.negotiate_protocol_version("2025-06-18")
  request = MCProtocol.parse_message(message_data, protocol_version: version)
rescue MCProtocol::UnsupportedProtocolVersionError => ex
  puts "Unsupported protocol version: #{ex.message}"
rescue MCProtocol::ParseError => ex
  puts "Failed to parse MCP message: #{ex.message}"
end
```

## Protocol Version Migration

Migrating from 2025-03-26 to 2025-06-18:

```crystal
# Check what's available in your protocol version
def handle_tool_call(request, protocol_version)
  result = execute_tool(request)
  
  if MCProtocol.feature_available?("structured_content", protocol_version)
    # Use enhanced CallToolResult with structured content
    MCProtocol::CallToolResult.new(
      content: [MCProtocol::TextContent.new("Tool executed successfully")],
      structuredContent: JSON::Any.new({"status" => "success"})
    )
  else
    # Use basic CallToolResult for older clients
    MCProtocol::CallToolResult.new(
      content: [MCProtocol::TextContent.new("Tool executed successfully")]
    )
  end
end
```

## Security Considerations

When implementing MCP servers with elicitation:

1. **Validate all inputs** - Especially user-provided elicitation responses
2. **Implement proper authentication** - Use OAuth 2.0 for remote servers
3. **Limit resource access** - Only expose necessary data and tools
4. **Sanitize elicitation schemas** - Prevent injection attacks through form fields
5. **Log security events** - Monitor for suspicious activity
6. **Handle errors gracefully** - Don't leak sensitive information

## Examples

See the `examples/` directory for complete working examples:

- **`elicitation_example.cr`**: Complete elicitation system workflows
- **`schema_examples.cr`**: Schema definition and validation examples  
- **`content_blocks_example.cr`**: Enhanced content blocks with ResourceLink
- **`basic_server.cr`**: Simple tool and resource server
- **`sse_server.cr`**: Server-Sent Events implementation

## Development

Build and test the library:

```bash
# Build the library
crystal build src/mcprotocol.cr

# Run tests (87 passing tests)
crystal spec

# Run examples
crystal run examples/elicitation_example.cr
crystal run examples/schema_examples.cr
```

## Testing

```bash
# Full test suite
crystal spec

# Test specific features
crystal spec spec/elicitation_system_spec.cr
crystal spec spec/schema_system_spec.cr
crystal spec spec/backward_compatibility_spec.cr
```

## Migration Guide

For detailed migration information from older MCP versions:

- **`BREAKING_CHANGES.md`** - Complete list of breaking changes and solutions
- **`MIGRATION_SCRIPT.md`** - Automated migration assistance and scripts

## Contributing

1. Fork it (<https://github.com/nobodywasishere/mcprotocol/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

MIT License - see [LICENSE](LICENSE) for details.

## Related Projects

- [Official MCP Specification](https://spec.modelcontextprotocol.io/)
- [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)  
- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- [Claude Desktop MCP Integration](https://docs.anthropic.com/en/docs/agents-and-tools/mcp)

## Contributors

- [Margret Riegert](https://github.com/nobodywasishere) - creator and maintainer

---

**Ready for Production** ✨ | **MCP 2025-06-18 Complete** 🚀 | **87 Tests Passing** ✅
