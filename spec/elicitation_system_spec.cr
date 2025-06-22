require "./spec_helper"

describe "Elicitation System" do
  describe MCProtocol::ElicitRequest do
    it "creates a valid elicit request" do
             # Create a schema for the form
       properties = Hash(String, MCProtocol::PrimitiveSchemaDefinition).new
       properties["name"] = MCProtocol::StringSchema.new(description: "Your name")
       properties["age"] = MCProtocol::NumberSchema.new("integer", minimum: 0, maximum: 120)
       properties["subscribe"] = MCProtocol::BooleanSchema.new(default: false)
      
      schema = MCProtocol::ElicitRequestSchema.new(properties, required: ["name"])
      params = MCProtocol::ElicitRequestParams.new("Please fill out this form", schema)
      request = MCProtocol::ElicitRequest.new(params)

      request.method.should eq("elicitation/create")
      request.params.message.should eq("Please fill out this form")
      request.params.requested_schema.type.should eq("object")
      request.params.requested_schema.properties.should eq(properties)
      request.params.requested_schema.required.should eq(["name"])
    end

         it "serializes to correct JSON structure" do
       properties = Hash(String, MCProtocol::PrimitiveSchemaDefinition).new
       properties["email"] = MCProtocol::StringSchema.new(format: "email")
      schema = MCProtocol::ElicitRequestSchema.new(properties)
      params = MCProtocol::ElicitRequestParams.new("Enter your email", schema)
      request = MCProtocol::ElicitRequest.new(params)

      json = request.to_json
      json.should contain("\"method\":\"elicitation/create\"")
      json.should contain("\"message\":\"Enter your email\"")
      json.should contain("\"type\":\"object\"")
      json.should contain("\"properties\":")
    end

    it "deserializes from JSON correctly" do
      json = %(
        {
          "method": "elicitation/create",
          "params": {
            "message": "Please provide information",
            "requestedSchema": {
              "type": "object",
              "properties": {
                "name": {
                  "type": "string",
                  "description": "Your name"
                }
              },
              "required": ["name"]
            }
          }
        }
      )

      request = MCProtocol::ElicitRequest.from_json(json)
      request.method.should eq("elicitation/create")
      request.params.message.should eq("Please provide information")
      request.params.requested_schema.type.should eq("object")
      request.params.requested_schema.required.should eq(["name"])
    end
  end

  describe MCProtocol::ElicitResult do
    it "creates accept result with content" do
      content = {
        "name" => "John Doe",
        "age" => 30,
        "active" => true
      } of String => String | Int32 | Bool

      result = MCProtocol::ElicitResult.new("accept", content)
      result.action.should eq("accept")
      result.content.should eq(content)
      result.meta.should be_nil
    end

    it "creates decline result without content" do
      result = MCProtocol::ElicitResult.new("decline")
      result.action.should eq("decline")
      result.content.should be_nil
    end

    it "creates cancel result" do
      result = MCProtocol::ElicitResult.new("cancel")
      result.action.should eq("cancel")
      result.content.should be_nil
    end

    it "validates action values" do
      expect_raises(ArgumentError, "ElicitResult action must be 'accept', 'decline', or 'cancel'") do
        MCProtocol::ElicitResult.new("invalid")
      end
    end

    it "serializes to correct JSON" do
      content = {"username" => "test", "count" => 42} of String => String | Int32 | Bool
      result = MCProtocol::ElicitResult.new("accept", content)
      
      json = result.to_json
      json.should contain("\"action\":\"accept\"")
      json.should contain("\"content\":")
      json.should contain("\"username\":\"test\"")
      json.should contain("\"count\":42")
    end

    it "deserializes from JSON correctly" do
      json = %(
        {
          "action": "accept",
          "content": {
            "name": "Alice",
            "age": 25,
            "subscribe": true
          }
        }
      )

      result = MCProtocol::ElicitResult.from_json(json)
      result.action.should eq("accept")
      result.content.should_not be_nil
      content = result.content.not_nil!
      content["name"].should eq("Alice")
      content["age"].should eq(25)
      content["subscribe"].should eq(true)
    end

    it "handles decline action JSON" do
      json = %({"action": "decline"})
      result = MCProtocol::ElicitResult.from_json(json)
      result.action.should eq("decline")
      result.content.should be_nil
    end
  end

  describe "Integration: Complete Elicitation Workflow" do
    it "demonstrates complete elicitation flow" do
             # 1. Server creates an elicitation request
       properties = Hash(String, MCProtocol::PrimitiveSchemaDefinition).new
       properties["project_name"] = MCProtocol::StringSchema.new(
         description: "Name of your project",
         min_length: 1,
         max_length: 50
       )
       properties["language"] = MCProtocol::EnumSchema.new(
         ["crystal", "ruby", "python", "javascript"],
         enum_names: ["Crystal", "Ruby", "Python", "JavaScript"],
         description: "Programming language"
       )
       properties["public"] = MCProtocol::BooleanSchema.new(
         default: false,
         description: "Make project public"
       )

      schema = MCProtocol::ElicitRequestSchema.new(properties, required: ["project_name", "language"])
      params = MCProtocol::ElicitRequestParams.new("Create a new project", schema)
      request = MCProtocol::ElicitRequest.new(params)

      # 2. Serialize the request (as server would send to client)
      request_json = request.to_json
      request_json.should contain("elicitation/create")

      # 3. Client receives and processes (deserialize)
      received_request = MCProtocol::ElicitRequest.from_json(request_json)
      received_request.params.message.should eq("Create a new project")

      # 4. User fills out the form, client creates response
      user_data = {
        "project_name" => "my-awesome-app",
        "language" => "crystal",
        "public" => true
      } of String => String | Int32 | Bool

      response = MCProtocol::ElicitResult.new("accept", user_data)

      # 5. Serialize the response (as client would send to server)
      response_json = response.to_json
      response_json.should contain("accept")

      # 6. Server receives the response
      received_response = MCProtocol::ElicitResult.from_json(response_json)
      received_response.action.should eq("accept")
      
      content = received_response.content.not_nil!
      content["project_name"].should eq("my-awesome-app")
      content["language"].should eq("crystal")
      content["public"].should eq(true)
    end
  end
end 