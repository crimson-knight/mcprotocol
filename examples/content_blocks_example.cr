require "../src/mcprotocol"

# Content Blocks System Examples  
# Demonstrates the MCP 2025-06-18 enhanced content block system with ResourceLink

module ContentBlocksExample
  extend self

  # Example: Basic content blocks
  def basic_content_blocks
    puts "📄 Basic Content Block Examples"
    puts "=" * 40

    # Text content
    text_content = MCProtocol::TextContent.new(
      "Welcome to the enhanced MCP protocol! This text content supports rich metadata and improved functionality.",
      meta: {"source" => JSON::Any.new("welcome_guide")}
    )
    
    puts "📝 Text Content Block:"
    puts text_content.to_pretty_json
    puts

    # Image content  
    image_content = MCProtocol::ImageContent.new(
      data: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChAHW",
      mimeType: "image/png",
      meta: {
        "description" => JSON::Any.new("Sample 1x1 pixel image"),
        "created_by" => JSON::Any.new("content_generator")
      }
    )
    
    puts "🖼️  Image Content Block:"
    puts image_content.to_pretty_json
    puts

    # Embedded resource (using TextResourceContents)
    embedded_resource = MCProtocol::EmbeddedResource.new(
      resource: MCProtocol::TextResourceContents.new(
        "# Example Documentation\n\nThis is example markdown content.",
        uri: URI.parse("file:///docs/example.md"),
        mimeType: "text/markdown"
      ),
      meta: {"context" => JSON::Any.new("help_system")}
    )
    
    puts "📁 Embedded Resource Block:"
    puts embedded_resource.to_pretty_json
  end

  # Example: ResourceLink content blocks
  def resource_link_examples
    puts "\n🔗 ResourceLink Content Block Examples"
    puts "=" * 45

    # File resource link
    file_link = MCProtocol::ResourceLink.new(
      name: "user_guide",
      uri: "file:///docs/user_guide.pdf",
      title: "User Guide PDF",
      description: "Comprehensive user guide for the application",
      meta: {
        "file_size" => JSON::Any.new("2.4MB"),
        "last_updated" => JSON::Any.new("2025-06-18T10:30:00Z")
      }
    )
    
    puts "📄 File Resource Link:"
    puts file_link.to_pretty_json
    puts

    # Web resource link
    web_link = MCProtocol::ResourceLink.new(
      name: "api_documentation",
      uri: "https://api.example.com/docs",
      title: "API Documentation",
      description: "Live API documentation with interactive examples",
      meta: {
        "requires_auth" => JSON::Any.new(true),
        "rate_limited" => JSON::Any.new(false)
      }
    )
    
    puts "🌐 Web Resource Link:"
    puts web_link.to_pretty_json
    puts

    # Database resource link
    db_link = MCProtocol::ResourceLink.new(
      name: "user_analytics",
      uri: "postgres://localhost/analytics?table=users",
      title: "User Analytics Data",
      description: "Real-time user behavior analytics from the database",
      meta: {
        "row_count" => JSON::Any.new(15420),
        "updated" => JSON::Any.new("live")
      }
    )
    
    puts "🗄️  Database Resource Link:"
    puts db_link.to_pretty_json
  end

  # Example: Mixed content arrays
  def mixed_content_examples
    puts "\n🎭 Mixed Content Block Arrays"
    puts "=" * 35

    # Create mixed content for a rich message
    content_blocks = [
      MCProtocol::TextContent.new("Here's a summary of the project status:").as(MCProtocol::ContentBlock),
      
      MCProtocol::ResourceLink.new(
        name: "project_dashboard",
        uri: "https://dashboard.example.com/project/123",
        title: "Project Dashboard",
        description: "Live project metrics and progress tracking"
      ).as(MCProtocol::ContentBlock),
      
      MCProtocol::TextContent.new("\nKey metrics from the latest report:").as(MCProtocol::ContentBlock),
      
      MCProtocol::ResourceLink.new(
        name: "metrics_report",
        uri: "file:///reports/weekly_metrics.xlsx",
        title: "Weekly Metrics Report",
        description: "Detailed performance metrics for the current sprint"
      ).as(MCProtocol::ContentBlock),
      
      MCProtocol::TextContent.new("\nTeam photo from our latest meeting:").as(MCProtocol::ContentBlock),
      
      MCProtocol::ImageContent.new(
        data: "R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7",
        mimeType: "image/gif"
      ).as(MCProtocol::ContentBlock)
    ]

    puts "🎯 Rich Content Message with Mixed Blocks:"
    content_blocks.each_with_index do |block, index|
      puts "\nBlock #{index + 1} (#{block.type}):"
      puts block.to_pretty_json
    end
  end

  # Example: PromptMessage with content blocks
  def prompt_message_example
    puts "\n💬 PromptMessage with Content Blocks"
    puts "=" * 40

    # Create prompt message with primary content (single content block)
    primary_content = MCProtocol::TextContent.new(
      "Please analyze the Q4 financial report and provide insights on revenue trends, cost analysis, and future projections.",
      meta: {"request_type" => JSON::Any.new("analysis")}
    )

    # Create prompt message
    prompt_message = MCProtocol::PromptMessage.new(
      content: primary_content.as(MCProtocol::ContentBlock),
      role: MCProtocol::Role::User
    )
    
    puts "📩 Prompt Message with Content:"
    puts prompt_message.to_pretty_json
    puts
    
    # Additional resource link example (separate content block)
    resource_content = MCProtocol::ResourceLink.new(
      name: "financial_report",
      uri: "file:///uploads/q4_financial_report.pdf",
      title: "Q4 Financial Report",
      description: "Quarterly financial performance report with detailed analysis"
    )
    
    # Create another prompt message with resource link
    resource_message = MCProtocol::PromptMessage.new(
      content: resource_content.as(MCProtocol::ContentBlock),
      role: MCProtocol::Role::User
    )

    puts "🔗 Prompt Message with Resource Link:"
    puts resource_message.to_pretty_json
  end

  # Example: CallToolResult with structured content
  def call_tool_result_example
    puts "\n🔧 CallToolResult with Structured Content"
    puts "=" * 45

    # Create content blocks for tool result
    result_content = [
      MCProtocol::TextContent.new("File processing completed successfully.").as(MCProtocol::ContentBlock),
      
      MCProtocol::ResourceLink.new(
        name: "processed_file",
        uri: "file:///output/processed_data.json",
        title: "Processed Data Output",
        description: "JSON file containing the processed results"
      ).as(MCProtocol::ContentBlock),
      
      MCProtocol::TextContent.new("Processing statistics:\n- Records processed: 1,247\n- Errors encountered: 0\n- Processing time: 2.3 seconds").as(MCProtocol::ContentBlock)
    ]

    # Structured content data (convert to JSON::Any)
    structured_content_hash = {
      "status" => JSON::Any.new("success"),
      "recordsProcessed" => JSON::Any.new(1247),
      "errors" => JSON::Any.new(0),
      "processingTimeMs" => JSON::Any.new(2300),
      "outputFile" => JSON::Any.new("/output/processed_data.json")
    }
    structured_content = JSON::Any.new(structured_content_hash)

    # Create tool result
    tool_result = MCProtocol::CallToolResult.new(
      content: result_content,
      isError: false,
      structuredContent: structured_content
    )

    puts "⚙️  Tool Result with Rich Content:"
    puts tool_result.to_pretty_json
  end

  # Example: Content block metadata patterns
  def metadata_patterns_example
    puts "\n🏷️  Content Block Metadata Patterns"
    puts "=" * 40

    # Text content with rich metadata
    documented_text = MCProtocol::TextContent.new(
      "This is a code snippet that demonstrates the new feature implementation.",
      meta: {
        "content_type" => JSON::Any.new("code_snippet"),
        "language" => JSON::Any.new("crystal"),
        "author" => JSON::Any.new("development_team"),
        "created_at" => JSON::Any.new("2025-06-18T14:30:00Z"),
        "tags" => JSON::Any.new(["example", "tutorial", "new_feature"].map { |s| JSON::Any.new(s) }),
        "confidence_score" => JSON::Any.new(0.95)
      }
    )

    puts "📝 Text with Rich Metadata:"
    puts documented_text.to_pretty_json
    puts

    # Image with detailed metadata
    diagram_image = MCProtocol::ImageContent.new(
      data: "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAAQAAAAEAB",
      mimeType: "image/png",
      meta: {
        "content_type" => JSON::Any.new("architecture_diagram"),
        "diagram_type" => JSON::Any.new("system_architecture"),
        "created_by" => JSON::Any.new("architect"),
        "dimensions" => JSON::Any.new("1920x1080"),
        "created_at" => JSON::Any.new("2025-06-18T09:15:00Z"),
        "version" => JSON::Any.new("2.1"),
        "components_shown" => JSON::Any.new(["api", "database", "cache", "frontend"].map { |s| JSON::Any.new(s) })
      }
    )

    puts "🖼️  Image with Detailed Metadata:"
    puts diagram_image.to_pretty_json
    puts

    # ResourceLink with access metadata
    secure_resource = MCProtocol::ResourceLink.new(
      name: "classified_document",
      uri: "secure://vault.company.com/docs/classified/project_x.pdf",
      title: "Project X Specification",
      description: "Confidential project specification document",
      meta: {
        "security_level" => JSON::Any.new("confidential"),
        "requires_clearance" => JSON::Any.new(true),
        "access_logged" => JSON::Any.new(true),
        "expiry_date" => JSON::Any.new("2025-12-31"),
        "department" => JSON::Any.new("research_and_development"),
        "classification" => JSON::Any.new("internal_use_only")
      }
    )

    puts "🔒 Secure Resource with Access Metadata:"
    puts secure_resource.to_pretty_json
  end

  # Example: Content block validation
  def content_validation_example
    puts "\n✅ Content Block Validation Examples"
    puts "=" * 40

    puts "1. Text Content Validation:"
    puts "   - Text field is required and non-empty"
    puts "   - Type must be 'text'"
    puts "   - Meta field is optional but must be valid JSON object"
    puts

    puts "2. ResourceLink Validation:"
    puts "   - Name field is required (programmatic identifier)"
    puts "   - URI field is required and must be valid URI format"
    puts "   - Title is optional (human-readable name)"
    puts "   - Description is optional (detailed explanation)"
    puts "   - Type must be 'resource_link'"
    puts

    puts "3. Image Content Validation:"
    puts "   - Data field must be valid base64 encoded image"
    puts "   - MimeType must be valid image MIME type"
    puts "   - Type must be 'image'"
    puts

    puts "4. General Content Block Rules:"
    puts "   - All content blocks must have a valid 'type' field"
    puts "   - Meta fields should follow consistent naming conventions"
    puts "   - Content should be meaningful and contextually relevant"
  end

  # Run all examples
  def run_all_examples
    puts "🎯 Content Blocks System Examples"
    puts "=" * 50
    
    basic_content_blocks
    resource_link_examples
    mixed_content_examples
    prompt_message_example
    call_tool_result_example
    metadata_patterns_example
    content_validation_example
    
    puts "\n✨ All content block examples completed!"
    puts "Use these patterns to create rich, interactive content in your MCP applications."
  end
end

# Run examples if executed directly
if PROGRAM_NAME.includes?("content_blocks_example")
  ContentBlocksExample.run_all_examples
end 