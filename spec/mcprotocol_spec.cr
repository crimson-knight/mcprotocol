require "./spec_helper"

describe MCProtocol do
  describe "MCP Protocol 2025-06-18 Upgrade Integration" do
    it "demonstrates complete protocol upgrade features" do
      # This integration test demonstrates the key features of the 2025-06-18 upgrade
      
      # 1. ✅ Schema Definition System
      boolean_schema = MCProtocol::BooleanSchema.new(description: "Enable feature")
      number_schema = MCProtocol::NumberSchema.new("integer", minimum: 1, maximum: 100)
      string_schema = MCProtocol::StringSchema.new(format: "email")
      enum_schema = MCProtocol::EnumSchema.new(["small", "medium", "large"])
      
      # All schemas can be used as PrimitiveSchemaDefinition
      schemas = [boolean_schema, number_schema, string_schema, enum_schema] of MCProtocol::PrimitiveSchemaDefinition
      schemas.size.should eq(4)

             # 2. ✅ Elicitation System - Server requesting user input
       properties = Hash(String, MCProtocol::PrimitiveSchemaDefinition).new
       properties["user_email"] = string_schema
       properties["size_preference"] = enum_schema  
       properties["enable_notifications"] = boolean_schema
       properties["max_items"] = number_schema
      
      schema = MCProtocol::ElicitRequestSchema.new(properties, required: ["user_email"])
      params = MCProtocol::ElicitRequestParams.new("Please configure your preferences", schema)
      elicit_request = MCProtocol::ElicitRequest.new(params)
      
      elicit_request.method.should eq("elicitation/create")
      elicit_request.params.requested_schema.properties.size.should eq(4)

      # 3. ✅ Enhanced Content System
      text_content = MCProtocol::TextContent.new("Configuration file updated:")
      resource_link = MCProtocol::ResourceLink.new(
        "app-config",
        "file:///app/config.json",
        title: "Application Configuration",
        description: "Main app settings"
      )
      
      # Content blocks can contain mixed content types
      content_blocks = [text_content, resource_link] of MCProtocol::ContentBlock
      content_blocks.size.should eq(2)

      # 4. ✅ BaseMetadata Pattern - Consistent naming
      metadata = MCProtocol::BaseMetadata.new("database_connector", "Database Connector")
      metadata.name.should eq("database_connector")  # Programmatic
      metadata.title.should eq("Database Connector")  # User-facing

      # 5. ✅ ResourceTemplateReference - Enhanced references
      template_ref = MCProtocol::ResourceTemplateReference.new("file:///templates/{id}")
      template_ref.type.should eq("ref/resource")

      # 6. ✅ Enhanced Client Capabilities
      elicitation_capability = JSON::Any.new({} of String => JSON::Any)
      capabilities = MCProtocol::ClientCapabilities.new(elicitation: elicitation_capability)
      capabilities.elicitation.should_not be_nil

             # 7. ✅ Updated Request/Result Unions
       # ElicitRequest can be used as ServerRequest
       server_request = elicit_request.as(MCProtocol::ServerRequest)
       server_request.should be_a(MCProtocol::ElicitRequest)

       # ElicitResult can be used as ClientResult
       user_response = MCProtocol::ElicitResult.new("accept", {
         "user_email" => "user@example.com",
         "size_preference" => "medium", 
         "enable_notifications" => true,
         "max_items" => 50
       } of String => String | Int32 | Bool)
       
       client_result = user_response.as(MCProtocol::ClientResult)
       client_result.should be_a(MCProtocol::ElicitResult)

      # 8. ✅ JSON Serialization/Deserialization Works
      elicit_json = elicit_request.to_json
      elicit_json.should contain("elicitation/create")
      
      result_json = user_response.to_json  
      result_json.should contain("accept")
      
      content_json = resource_link.to_json
      content_json.should contain("resource_link")

      # All core features of the 2025-06-18 upgrade are working! 🎉
    end

    it "validates backward compatibility" do
      # Ensure existing types still work
      text = MCProtocol::TextContent.new("Hello, world!")
      text.text.should eq("Hello, world!")
      text.type.should eq("text")

             # Existing unions still work
       old_content = text.as(MCProtocol::ContentBlock)
       old_content.should be_a(MCProtocol::TextContent)
    end

    it "demonstrates elicitation workflow end-to-end" do
      # Complete workflow from server request to client response
      
             # Server creates structured form request
       properties = Hash(String, MCProtocol::PrimitiveSchemaDefinition).new
       properties["project_name"] = MCProtocol::StringSchema.new(
         description: "Enter project name",
         min_length: 1,
         max_length: 50
       )
       properties["language"] = MCProtocol::EnumSchema.new(
         ["crystal", "ruby", "python"],
         enum_names: ["Crystal", "Ruby", "Python"]
       )
      
      schema = MCProtocol::ElicitRequestSchema.new(properties, required: ["project_name"])
      params = MCProtocol::ElicitRequestParams.new("Create new project", schema)
      request = MCProtocol::ElicitRequest.new(params)

      # Serialize for network transmission
      request_json = request.to_json
      
      # Client receives and deserializes
      received_request = MCProtocol::ElicitRequest.from_json(request_json)
      received_request.params.message.should eq("Create new project")
      
      # User fills form, client creates response
      response = MCProtocol::ElicitResult.new("accept", {
        "project_name" => "awesome-app",
        "language" => "crystal"
      } of String => String | Int32 | Bool)
      
      # Serialize response
      response_json = response.to_json
      
      # Server receives and processes
      received_response = MCProtocol::ElicitResult.from_json(response_json)
      received_response.action.should eq("accept")
      content = received_response.content.not_nil!
      content["project_name"].should eq("awesome-app")
      content["language"].should eq("crystal")
      
      # Workflow complete! ✅
    end
  end
end
