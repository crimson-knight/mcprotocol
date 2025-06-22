require "./spec_helper"

describe "Backward Compatibility Tests - MCP Protocol Versions" do
  describe "Protocol Version Negotiation" do
    it "defaults to latest protocol version" do
      version = MCProtocol.negotiate_protocol_version(nil)
      version.should eq("2025-06-18")
    end

    it "accepts supported protocol versions" do
      version = MCProtocol.negotiate_protocol_version("2025-03-26")
      version.should eq("2025-03-26")
      
      version = MCProtocol.negotiate_protocol_version("2025-06-18")
      version.should eq("2025-06-18")
    end

    it "rejects unsupported protocol versions" do
      expect_raises(MCProtocol::UnsupportedProtocolVersionError, /Unsupported protocol version: 2024-01-01/) do
        MCProtocol.negotiate_protocol_version("2024-01-01")
      end
    end

    it "lists supported versions in error message" do
      expect_raises(MCProtocol::UnsupportedProtocolVersionError, /2025-06-18, 2025-03-26/) do
        MCProtocol.negotiate_protocol_version("invalid")
      end
    end
  end

  describe "Feature Availability Checks" do
    it "correctly identifies 2025-06-18 features" do
      # Features only in 2025-06-18
      MCProtocol.feature_available?("elicitation", "2025-06-18").should be_true
      MCProtocol.feature_available?("meta_fields", "2025-06-18").should be_true
      MCProtocol.feature_available?("base_metadata_pattern", "2025-06-18").should be_true
      MCProtocol.feature_available?("enhanced_tools", "2025-06-18").should be_true
      
      # Features not in 2025-03-26
      MCProtocol.feature_available?("elicitation", "2025-03-26").should be_false
      MCProtocol.feature_available?("meta_fields", "2025-03-26").should be_false
    end

    it "correctly identifies common features" do
      # Features available in both versions
      MCProtocol.feature_available?("content_blocks", "2025-06-18").should be_true
      MCProtocol.feature_available?("content_blocks", "2025-03-26").should be_true
      MCProtocol.feature_available?("basic_protocol", "2025-06-18").should be_true
      MCProtocol.feature_available?("basic_protocol", "2025-03-26").should be_true
    end

    it "defaults to latest version when version not specified" do
      MCProtocol.feature_available?("elicitation").should be_true
      MCProtocol.feature_available?("meta_fields").should be_true
    end

    it "returns false for unknown features" do
      MCProtocol.feature_available?("unknown_feature").should be_false
      MCProtocol.feature_available?("future_feature", "2025-06-18").should be_false
    end
  end

  describe "Parse Message with Protocol Versions" do
    it "handles elicitation requests in 2025-06-18" do
      # Test elicitation feature availability in 2025-06-18
      MCProtocol.feature_available?("elicitation", "2025-06-18").should be_true
      
      # Create and test elicitation request directly
      string_schema = MCProtocol::StringSchema.new(
        description: "Test field",
        title: "Test"
      )
      
      schema = MCProtocol::ElicitRequestSchema.new(
        properties: {"test" => string_schema.as(MCProtocol::PrimitiveSchemaDefinition)}
      )
      
      params = MCProtocol::ElicitRequestParams.new(
        message: "Test message",
        requested_schema: schema
      )
      
      request = MCProtocol::ElicitRequest.new(params: params)
      json = request.to_json
      
      # Should serialize and deserialize successfully
      parsed = MCProtocol::ElicitRequest.from_json(json)
      parsed.should be_a(MCProtocol::ElicitRequest)
      parsed.params.message.should eq("Test message")
    end

    it "rejects elicitation requests in 2025-03-26" do
      expect_raises(MCProtocol::UnsupportedProtocolVersionError, /Elicitation not supported/) do
        MCProtocol.parse_message("{}", method: "elicitation/create", protocol_version: "2025-03-26")
      end
    end

    it "handles common methods in both protocol versions" do
      # Test a basic request that should work in both versions
      tools_request = %({
        "method": "tools/list",
        "id": "test-123",
        "params": {}
      })
      
      # Should work in both versions
      parsed_new = MCProtocol.parse_message(tools_request, method: "tools/list", protocol_version: "2025-06-18")
      parsed_old = MCProtocol.parse_message(tools_request, method: "tools/list", protocol_version: "2025-03-26")
      
      parsed_new.should be_a(MCProtocol::ListToolsRequest)
      parsed_old.should be_a(MCProtocol::ListToolsRequest)
    end

    it "handles unknown methods gracefully" do
      expect_raises(MCProtocol::ParseError, /Unknown method: invalid\/method/) do
        MCProtocol.parse_message("{}", method: "invalid/method")
      end
    end
  end

  describe "Legacy Type Compatibility" do
    it "handles types without new fields in 2025-06-18" do
      # Create a resource without the new title and meta fields
      resource = MCProtocol::Resource.new(
        name: "legacy_resource",
        uri: URI.parse("file:///legacy.txt")
        # No title, meta, etc.
      )
      
      json = resource.to_json
      parsed = MCProtocol::Resource.from_json(json)
      
      parsed.name.should eq("legacy_resource")
      parsed.title.should be_nil
      parsed.meta.should be_nil
    end

    it "handles tools without new output schema" do
      input_schema = MCProtocol::ToolInputSchema.new
      
      tool = MCProtocol::Tool.new(
        inputSchema: input_schema,
        name: "legacy_tool"
        # No outputSchema, title, meta
      )
      
      json = tool.to_json
      parsed = MCProtocol::Tool.from_json(json)
      
      parsed.name.should eq("legacy_tool")
      parsed.outputSchema.should be_nil
      parsed.title.should be_nil
      parsed.meta.should be_nil
    end

    it "handles prompts without title field" do
      prompt = MCProtocol::Prompt.new(
        name: "legacy_prompt"
        # No title, meta
      )
      
      json = prompt.to_json
      parsed = MCProtocol::Prompt.from_json(json)
      
      parsed.name.should eq("legacy_prompt")
      parsed.title.should be_nil
      parsed.meta.should be_nil
    end

    it "handles content without meta fields" do
      text_content = MCProtocol::TextContent.new("Legacy content")
      
      json = text_content.to_json
      parsed = MCProtocol::TextContent.from_json(json)
      
      parsed.text.should eq("Legacy content")
      parsed.meta.should be_nil
    end
  end

  describe "JSON Serialization Compatibility" do
    it "omits null fields from JSON output" do
      resource = MCProtocol::Resource.new(
        name: "test_resource",
        uri: URI.parse("file:///test.txt")
      )
      
      json = resource.to_json
      
      # Should not include null fields
      json.should_not contain("\"title\":null")
      json.should_not contain("\"meta\":null")
      json.should contain("\"name\":\"test_resource\"")
    end

    it "includes fields when they have values" do
      resource = MCProtocol::Resource.new(
        name: "test_resource",
        uri: URI.parse("file:///test.txt"),
        title: "Test Resource",
        meta: {"test" => JSON::Any.new("value")}
      )
      
      json = resource.to_json
      
      json.should contain("\"title\":\"Test Resource\"")
      json.should contain("\"_meta\":{\"test\":\"value\"}")
    end
  end

  describe "Version-Aware Content Handling" do
    it "handles ContentBlock types gracefully" do
      # ResourceLink is new to 2025-06-18
      resource_link = MCProtocol::ResourceLink.new(
        name: "new_resource",
        uri: "file:///new.txt",
        title: "New Resource"
      )
      
      # Should serialize and deserialize correctly
      json = resource_link.to_json
      parsed = MCProtocol::ResourceLink.from_json(json)
      
      parsed.name.should eq("new_resource")
      parsed.title.should eq("New Resource")
      parsed.type.should eq("resource_link")
    end

    it "maintains existing content types" do
      # TextContent works in both versions
      text_content = MCProtocol::TextContent.new("Test content")
      
      json = text_content.to_json
      parsed = MCProtocol::TextContent.from_json(json)
      
      parsed.text.should eq("Test content")
      parsed.type.should eq("text")
    end
  end

  describe "Error Handling Compatibility" do
    it "provides clear error messages for version mismatches" do
      expect_raises(MCProtocol::UnsupportedProtocolVersionError) do
        MCProtocol.parse_message("{}", method: "elicitation/create", protocol_version: "2025-03-26")
      end
    end

    it "handles malformed JSON gracefully" do
      expect_raises(JSON::ParseException) do
        MCProtocol.parse_message("invalid json", method: "tools/list")
      end
    end

    it "provides helpful error for missing method" do
      expect_raises(MCProtocol::ParseError, /Method cannot be nil/) do
        MCProtocol.parse_message("{}")
      end
    end
  end

  describe "Performance with Mixed Versions" do
    it "handles version detection efficiently" do
      start_time = Time.monotonic
      
      # Simulate many version checks
      1000.times do
        MCProtocol.feature_available?("elicitation", "2025-06-18")
        MCProtocol.feature_available?("basic_protocol", "2025-03-26")
      end
      
      end_time = Time.monotonic
      duration = end_time - start_time
      
      # Should be very fast (< 10ms for 2000 checks)
      duration.should be < 10.milliseconds
    end

    it "handles protocol negotiation efficiently" do
      start_time = Time.monotonic
      
      # Simulate many negotiations
      100.times do
        MCProtocol.negotiate_protocol_version("2025-06-18")
        MCProtocol.negotiate_protocol_version("2025-03-26")
        MCProtocol.negotiate_protocol_version(nil)
      end
      
      end_time = Time.monotonic
      duration = end_time - start_time
      
      # Should be very fast (< 5ms for 300 negotiations)
      duration.should be < 5.milliseconds
    end
  end
end 