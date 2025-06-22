require "../src/mcprotocol"

# Elicitation Workflow Example
# Demonstrates the MCP 2025-06-18 elicitation system for structured user input

module ElicitationExample
  extend self

  # Example: Create an elicitation request for user configuration
  def create_user_configuration_request
    # Define schema for user configuration form
    string_schema = MCProtocol::StringSchema.new(
      description: "User's display name for the interface",
      title: "Display Name",
      min_length: 1,
      max_length: 50
    )
    
    email_schema = MCProtocol::StringSchema.new(
      description: "User's email address for notifications",
      title: "Email Address",
      format: "email"
    )
    
    theme_schema = MCProtocol::EnumSchema.new(
      ["light", "dark", "auto"],
      enum_names: ["Light", "Dark", "Auto-detect"],
      description: "Preferred UI theme",
      title: "Theme"
    )
    
    notifications_schema = MCProtocol::BooleanSchema.new(
      description: "Enable email notifications",
      title: "Enable Notifications",
      default: true
    )
    
    max_items_schema = MCProtocol::NumberSchema.new(
      "integer",
      description: "Maximum items to show per page",
      title: "Items Per Page",
      minimum: 5,
      maximum: 100
    )
    
    # Create the complete schema
    schema = MCProtocol::ElicitRequestSchema.new(
      properties: {
        "displayName" => string_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "email" => email_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "theme" => theme_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "notifications" => notifications_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "maxItems" => max_items_schema.as(MCProtocol::PrimitiveSchemaDefinition)
      },
      required: ["displayName", "email"]
    )
    
    # Create the elicitation request
    params = MCProtocol::ElicitRequestParams.new(
      message: "Please configure your user preferences to personalize your experience.",
      requested_schema: schema
    )
    
    request = MCProtocol::ElicitRequest.new(
      params: params
    )
    
    puts "📋 Elicitation Request Created:"
    puts request.to_pretty_json
    
    request
  end

  # Example: Handle elicitation results
  def handle_elicitation_result(result_json : String)
    result = MCProtocol::ElicitResult.from_json(result_json)
    
    case result.action
    when "accept"
      puts "✅ User accepted configuration:"
      
      if content = result.content
        content.each do |key, value|
          puts "  #{key}: #{value}"
        end
        
        # Process the configuration
        process_user_configuration(content)
      end
      
    when "decline"
      puts "❌ User declined configuration"
      puts "Using default settings..."
      use_default_configuration
      
    when "cancel"
      puts "🚫 User cancelled configuration"
      puts "Configuration process aborted"
      
    else
      puts "⚠️  Unknown action: #{result.action}"
    end
  end

  # Example: Complex multi-step elicitation for project setup
  def create_project_setup_request
    # Step 1: Project basic info
    project_name_schema = MCProtocol::StringSchema.new(
      description: "Unique identifier for the project",
      title: "Project Name",
      min_length: 3,
      max_length: 30
    )
    
    project_type_schema = MCProtocol::EnumSchema.new(
      ["web_app", "api", "cli_tool", "library"],
      enum_names: ["Web Application", "REST API", "Command Line Tool", "Library"],
      description: "Type of project to create",
      title: "Project Type"
    )
    
    public_schema = MCProtocol::BooleanSchema.new(
      description: "Make this project publicly visible",
      title: "Public Project",
      default: false
    )
    
    # Create multi-field schema
    schema = MCProtocol::ElicitRequestSchema.new(
      properties: {
        "name" => project_name_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "type" => project_type_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "public" => public_schema.as(MCProtocol::PrimitiveSchemaDefinition)
      },
      required: ["name", "type"]
    )
    
    params = MCProtocol::ElicitRequestParams.new(
      message: "Let's set up your new project. Please provide the basic information below.",
      requested_schema: schema
    )
    
    MCProtocol::ElicitRequest.new(
      params: params
    )
  end

  # Example: Server-side elicitation workflow
  def run_server_elicitation_workflow
    puts "🚀 Starting Elicitation Workflow Demo"
    puts "=" * 50
    
    # Create a configuration request
    request = create_user_configuration_request
    
    puts "\n📤 Request would be sent to client..."
    puts "\n⏳ Waiting for user response..."
    
    # Simulate different types of responses
    demo_responses = [
      {
        action: "accept",
        content: {
          "displayName" => "Alice Developer",
          "email" => "alice@example.com",
          "theme" => "dark",
          "notifications" => true,
          "maxItems" => 50
        }
      },
      {
        action: "decline",
        content: nil
      },
      {
        action: "cancel",
        content: nil
      }
    ]
    
    demo_responses.each_with_index do |response, index|
      puts "\n" + "=" * 30
      puts "Demo Response #{index + 1}:"
      
      result = MCProtocol::ElicitResult.new(
        action: response[:action].as(String),
        content: response[:content].as(Hash(String, String | Int32 | Bool)?)
      )
      
      handle_elicitation_result(result.to_json)
    end
  end

  # Example: Validation and error handling
  def demonstrate_schema_validation
    puts "\n🔍 Schema Validation Examples:"
    puts "=" * 40
    
    # Valid string schema
    valid_string = MCProtocol::StringSchema.new(
      description: "A properly configured string field",
      title: "Valid String",
      min_length: 1,
      max_length: 100,
      format: "email"
    )
    
    puts "✅ Valid string schema:"
    puts valid_string.to_pretty_json
    
    # Number schema with constraints
    number_with_limits = MCProtocol::NumberSchema.new(
      "integer",
      description: "Age in years",
      title: "Age",
      minimum: 0,
      maximum: 150
    )
    
    puts "\n✅ Number schema with validation:"
    puts number_with_limits.to_pretty_json
    
    # Enum schema with display names
    status_enum = MCProtocol::EnumSchema.new(
      ["pending", "in_progress", "completed", "cancelled"],
      enum_names: ["Pending Review", "In Progress", "Completed", "Cancelled"],
      description: "Current status of the item",
      title: "Status"
    )
    
    puts "\n✅ Enum schema with friendly names:"
    puts status_enum.to_pretty_json
  end

  # Helper methods
  private def process_user_configuration(config)
    puts "🔧 Processing configuration..."
    puts "  - Setting display name: #{config["displayName"]}"
    puts "  - Configuring email: #{config["email"]}"
    puts "  - Applying theme: #{config["theme"]}"
    puts "  - Notifications: #{config["notifications"] ? "enabled" : "disabled"}"
    puts "  - Items per page: #{config["maxItems"]}"
  end

  private def use_default_configuration
    puts "🔧 Using default configuration..."
    puts "  - Display name: Default User"
    puts "  - Theme: auto"
    puts "  - Notifications: enabled"
    puts "  - Items per page: 25"
  end
end

# Run the examples if this file is executed directly
if PROGRAM_NAME.includes?("elicitation_example")
  ElicitationExample.run_server_elicitation_workflow
  ElicitationExample.demonstrate_schema_validation
end 