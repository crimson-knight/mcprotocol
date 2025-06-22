require "../src/mcprotocol"

# Schema Definition System Examples
# Demonstrates the MCP 2025-06-18 schema types for validation and form generation

module SchemaExamples
  extend self

  # Example: Basic primitive schemas
  def basic_schema_examples
    puts "🔢 Basic Schema Type Examples"
    puts "=" * 40

    # Boolean Schema
    enable_feature = MCProtocol::BooleanSchema.new(
      description: "Enable the advanced features in the application",
      title: "Enable Advanced Features",
      default: false
    )
    
    puts "✅ Boolean Schema:"
    puts enable_feature.to_pretty_json
    puts

    # String Schema with format validation
    email_field = MCProtocol::StringSchema.new(
      description: "User's email address for account verification",
      title: "Email Address",
      format: "email",
      min_length: 5,
      max_length: 100
    )
    
    puts "📧 String Schema (Email):"
    puts email_field.to_pretty_json
    puts

    # Number Schema with constraints
    age_field = MCProtocol::NumberSchema.new(
      "integer",
      description: "User's age in years",
      title: "Age",
      minimum: 13,  # COPPA compliance
      maximum: 120
    )
    
    puts "🔢 Number Schema (Age):"
    puts age_field.to_pretty_json
    puts

    # Enum Schema with display names
    priority_field = MCProtocol::EnumSchema.new(
      ["low", "normal", "high", "urgent"],
      enum_names: ["Low Priority", "Normal Priority", "High Priority", "Urgent"],
      description: "Priority level for task processing",
      title: "Priority Level"
    )
    
    puts "📋 Enum Schema (Priority):"
    puts priority_field.to_pretty_json
  end

  # Example: Advanced string formats
  def string_format_examples
    puts "\n📝 String Format Validation Examples"
    puts "=" * 45

    # URI format
    website_field = MCProtocol::StringSchema.new(
      description: "Website URL for the organization",
      title: "Website",
      format: "uri"
    )
    
    puts "🌐 URI Format:"
    puts website_field.to_pretty_json
    puts

    # Date format
    birthday_field = MCProtocol::StringSchema.new(
      description: "Date of birth in YYYY-MM-DD format",
      title: "Date of Birth",
      format: "date"
    )
    
    puts "📅 Date Format:"
    puts birthday_field.to_pretty_json
    puts

    # Date-time format
    appointment_field = MCProtocol::StringSchema.new(
      description: "Appointment date and time in ISO 8601 format",
      title: "Appointment Time",
      format: "date-time"
    )
    
    puts "⏰ Date-Time Format:"
    puts appointment_field.to_pretty_json
  end

  # Example: Complex form schema
  def user_registration_form_schema
    puts "\n👤 User Registration Form Schema"
    puts "=" * 40

    # Create individual field schemas
    username_schema = MCProtocol::StringSchema.new(
      description: "Unique username for the account (3-20 characters, alphanumeric)",
      title: "Username",
      min_length: 3,
      max_length: 20
    )

    email_schema = MCProtocol::StringSchema.new(
      description: "Valid email address for account verification",
      title: "Email Address",
      format: "email"
    )

    age_schema = MCProtocol::NumberSchema.new(
      "integer",
      description: "Age in years (must be 13 or older)",
      title: "Age",
      minimum: 13,
      maximum: 120
    )

    country_schema = MCProtocol::EnumSchema.new(
      ["us", "ca", "uk", "de", "fr", "jp", "au"],
      enum_names: ["United States", "Canada", "United Kingdom", "Germany", "France", "Japan", "Australia"],
      description: "Country of residence",
      title: "Country"
    )

    newsletter_schema = MCProtocol::BooleanSchema.new(
      description: "Subscribe to our monthly newsletter",
      title: "Newsletter Subscription",
      default: false
    )

    # Combine into complete form schema
    form_schema = MCProtocol::ElicitRequestSchema.new(
      properties: {
        "username" => username_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "email" => email_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "age" => age_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "country" => country_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "newsletter" => newsletter_schema.as(MCProtocol::PrimitiveSchemaDefinition)
      },
      required: ["username", "email", "age", "country"]
    )

    puts "📝 Complete Registration Form Schema:"
    puts form_schema.to_pretty_json
    
    form_schema
  end

  # Example: Project configuration schema
  def project_configuration_schema
    puts "\n🚀 Project Configuration Schema"
    puts "=" * 40

    # Project name with constraints
    name_schema = MCProtocol::StringSchema.new(
      description: "Project name (must be unique, alphanumeric with dashes)",
      title: "Project Name",
      min_length: 3,
      max_length: 50
    )

    # Project type selection
    type_schema = MCProtocol::EnumSchema.new(
      ["webapp", "api", "mobile", "desktop", "library"],
      enum_names: ["Web Application", "REST API", "Mobile App", "Desktop Application", "Library/Package"],
      description: "Type of project to create",
      title: "Project Type"
    )

    # Programming language
    language_schema = MCProtocol::EnumSchema.new(
      ["javascript", "typescript", "python", "crystal", "go", "rust"],
      enum_names: ["JavaScript", "TypeScript", "Python", "Crystal", "Go", "Rust"],
      description: "Primary programming language",
      title: "Programming Language"
    )

    # Team size
    team_size_schema = MCProtocol::NumberSchema.new(
      "integer",
      description: "Expected team size for the project",
      title: "Team Size",
      minimum: 1,
      maximum: 50
    )

    # Public repository
    public_schema = MCProtocol::BooleanSchema.new(
      description: "Make the repository publicly visible",
      title: "Public Repository",
      default: false
    )

    # License selection
    license_schema = MCProtocol::EnumSchema.new(
      ["mit", "apache2", "gpl3", "bsd3", "unlicense", "proprietary"],
      enum_names: ["MIT License", "Apache 2.0", "GPL v3", "BSD 3-Clause", "Unlicense", "Proprietary"],
      description: "Open source license for the project",
      title: "License"
    )

    # Repository URL (optional)
    repo_url_schema = MCProtocol::StringSchema.new(
      description: "Existing repository URL (if migrating)",
      title: "Repository URL",
      format: "uri"
    )

    schema = MCProtocol::ElicitRequestSchema.new(
      properties: {
        "name" => name_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "type" => type_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "language" => language_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "teamSize" => team_size_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "public" => public_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "license" => license_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "repoUrl" => repo_url_schema.as(MCProtocol::PrimitiveSchemaDefinition)
      },
      required: ["name", "type", "language", "teamSize", "public", "license"]
    )

    puts "⚙️  Project Configuration Schema:"
    puts schema.to_pretty_json

    schema
  end

  # Example: API endpoint configuration
  def api_endpoint_schema
    puts "\n🔌 API Endpoint Configuration Schema"
    puts "=" * 45

    # Endpoint name
    name_schema = MCProtocol::StringSchema.new(
      description: "Descriptive name for the API endpoint",
      title: "Endpoint Name",
      min_length: 1,
      max_length: 100
    )

    # HTTP method
    method_schema = MCProtocol::EnumSchema.new(
      ["GET", "POST", "PUT", "PATCH", "DELETE"],
      enum_names: ["GET (Retrieve)", "POST (Create)", "PUT (Replace)", "PATCH (Update)", "DELETE (Remove)"],
      description: "HTTP method for the endpoint",
      title: "HTTP Method"
    )

    # Path pattern
    path_schema = MCProtocol::StringSchema.new(
      description: "URL path pattern (e.g., /api/users/{id})",
      title: "Path Pattern",
      min_length: 1,
      max_length: 200
    )

    # Authentication required
    auth_schema = MCProtocol::BooleanSchema.new(
      description: "Require authentication for this endpoint",
      title: "Authentication Required",
      default: true
    )

    # Rate limit (requests per minute)
    rate_limit_schema = MCProtocol::NumberSchema.new(
      "integer",
      description: "Maximum requests per minute per user",
      title: "Rate Limit",
      minimum: 1,
      maximum: 10000
    )

    # Response format
    format_schema = MCProtocol::EnumSchema.new(
      ["json", "xml", "html", "text"],
      enum_names: ["JSON", "XML", "HTML", "Plain Text"],
      description: "Response format for the endpoint",
      title: "Response Format"
    )

    schema = MCProtocol::ElicitRequestSchema.new(
      properties: {
        "name" => name_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "method" => method_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "path" => path_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "requireAuth" => auth_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "rateLimit" => rate_limit_schema.as(MCProtocol::PrimitiveSchemaDefinition),
        "responseFormat" => format_schema.as(MCProtocol::PrimitiveSchemaDefinition)
      },
      required: ["name", "method", "path", "requireAuth", "rateLimit", "responseFormat"]
    )

    puts "🔌 API Endpoint Schema:"
    puts schema.to_pretty_json

    schema
  end

  # Example: Schema validation demonstration
  def demonstrate_schema_validation
    puts "\n✅ Schema Validation Best Practices"
    puts "=" * 45

    puts "1. Always provide clear descriptions and titles"
    puts "2. Use appropriate formats for string validation"
    puts "3. Set reasonable min/max constraints for numbers"
    puts "4. Provide enum display names for better UX"
    puts "5. Use sensible defaults where appropriate"
    puts "6. Mark required fields clearly in the schema"
    puts

    # Example of well-structured schema
    contact_schema = MCProtocol::StringSchema.new(
      description: "Primary contact method - phone number in international format (e.g., +1-555-123-4567)",
      title: "Contact Phone",
      min_length: 10,
      max_length: 20
    )

    puts "📞 Well-Documented Contact Schema:"
    puts contact_schema.to_pretty_json
  end

  # Run all examples
  def run_all_examples
    puts "🎯 Schema Definition System Examples"
    puts "=" * 50
    
    basic_schema_examples
    string_format_examples
    user_registration_form_schema
    project_configuration_schema
    api_endpoint_schema
    demonstrate_schema_validation
    
    puts "\n✨ All schema examples completed!"
    puts "Use these patterns to create robust, user-friendly forms in your MCP applications."
  end
end

# Run examples if executed directly
if PROGRAM_NAME.includes?("schema_examples")
  SchemaExamples.run_all_examples
end 