require "./spec_helper"

describe "Integration Tests - MCP Protocol 2025-06-18" do
  describe "Method Type Mappings" do
    it "includes elicitation method in METHOD_TYPES" do
      MCProtocol::METHOD_TYPES.has_key?("elicitation/create").should be_true
      
      elicitation_mapping = MCProtocol::METHOD_TYPES["elicitation/create"]
      elicitation_mapping[0].should eq(MCProtocol::ElicitRequest)
      elicitation_mapping[1].should eq(MCProtocol::ElicitResult)
    end

    it "maintains all existing method mappings" do
      essential_methods = [
        "initialize", "resources/list", "tools/list", "tools/call"
      ]

      essential_methods.each do |method|
        MCProtocol::METHOD_TYPES.has_key?(method).should be_true
      end
    end
  end

  describe "End-to-End Elicitation Workflow" do
    it "supports complete elicitation cycle" do
      # Server creates request
      string_schema = MCProtocol::StringSchema.new(
        description: "Enter your name",
        title: "Name"
      )
      
      schema = MCProtocol::ElicitRequestSchema.new(
        properties: {"name" => string_schema.as(MCProtocol::PrimitiveSchemaDefinition)},
        required: ["name"]
      )
      
      params = MCProtocol::ElicitRequestParams.new(
        message: "Please provide your name",
        requested_schema: schema
      )
      
      request = MCProtocol::ElicitRequest.new(params: params)
      
      # Serialize and parse (simulating network)
      json = request.to_json
      parsed_request = MCProtocol::ElicitRequest.from_json(json)
      
      # Client responds  
      content_hash = Hash(String, String | Int32 | Bool).new
      content_hash["name"] = "John Doe"
      
      response = MCProtocol::ElicitResult.new(
        action: "accept",
        content: content_hash
      )
      
      response_json = response.to_json
      parsed_response = MCProtocol::ElicitResult.from_json(response_json)
      
      parsed_response.action.should eq("accept")
      parsed_response.content.not_nil!["name"].should eq("John Doe")
    end
  end

  describe "Enhanced Tool Workflow" do
    it "supports tools with output schemas and structured content" do
      # Create tool with output schema
      input_schema = MCProtocol::ToolInputSchema.new
      
      output_schema = JSON.parse(%({
        "type": "object",
        "properties": {"count": {"type": "number"}}
      }))
      
      tool = MCProtocol::Tool.new(
        inputSchema: input_schema,
        name: "count_tool",
        outputSchema: output_schema,
        title: "Count Tool"
      )
      
      # Tool result with structured content
      text_content = MCProtocol::TextContent.new("Found 5 items")
      structured_data = JSON.parse(%({"count": 5}))
      
      result = MCProtocol::CallToolResult.new(
        content: [text_content.as(MCProtocol::ContentBlock)],
        structuredContent: structured_data
      )
      
      result.structuredContent.not_nil!["count"].as_i.should eq(5)
    end
  end

  describe "Performance Testing" do
    it "handles large content arrays efficiently" do
      content_blocks = [] of MCProtocol::ContentBlock
      
      start_time = Time.monotonic
      
      100.times do |i|
        content_blocks << MCProtocol::TextContent.new(
          "Content #{i}"
        ).as(MCProtocol::ContentBlock)
      end
      
      result = MCProtocol::CallToolResult.new(content: content_blocks)
      json = result.to_json
      parsed = MCProtocol::CallToolResult.from_json(json)
      
      end_time = Time.monotonic
      duration = end_time - start_time
      
      duration.should be < 100.milliseconds
      parsed.content.size.should eq(100)
    end
  end

  describe "Backward Compatibility" do
    it "handles missing optional fields gracefully" do
      minimal_resource = MCProtocol::Resource.new(
        name: "test",
        uri: URI.parse("file:///test.txt")
      )
      
      json = minimal_resource.to_json
      parsed = MCProtocol::Resource.from_json(json)
      
      parsed.name.should eq("test")
      parsed.title.should be_nil
      parsed.meta.should be_nil
    end
  end
end 