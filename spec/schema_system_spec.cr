require "./spec_helper"

describe "Schema Definition System" do
  describe MCProtocol::BooleanSchema do
    it "creates a valid boolean schema with defaults" do
      schema = MCProtocol::BooleanSchema.new
      schema.type.should eq("boolean")
      schema.default.should be_nil
      schema.description.should be_nil
      schema.title.should be_nil
    end

    it "creates a boolean schema with all fields" do
      schema = MCProtocol::BooleanSchema.new(
        default: true,
        description: "A test boolean field",
        title: "Test Boolean"
      )
      schema.type.should eq("boolean")
      schema.default.should eq(true)
      schema.description.should eq("A test boolean field")
      schema.title.should eq("Test Boolean")
    end

    it "serializes to correct JSON" do
      schema = MCProtocol::BooleanSchema.new(
        default: false,
        description: "Test field",
        title: "My Field"
      )
      json = schema.to_json
      json.should contain("\"type\":\"boolean\"")
      json.should contain("\"default\":false")
      json.should contain("\"description\":\"Test field\"")
      json.should contain("\"title\":\"My Field\"")
    end

    it "deserializes from JSON correctly" do
      json = %({"type":"boolean","default":true,"description":"Test","title":"Boolean Field"})
      schema = MCProtocol::BooleanSchema.from_json(json)
      schema.type.should eq("boolean")
      schema.default.should eq(true)
      schema.description.should eq("Test")
      schema.title.should eq("Boolean Field")
    end
  end

  describe MCProtocol::NumberSchema do
    it "creates integer schema" do
      schema = MCProtocol::NumberSchema.new("integer", minimum: 0, maximum: 100)
      schema.type.should eq("integer")
      schema.minimum.should eq(0)
      schema.maximum.should eq(100)
    end

    it "creates number schema" do
      schema = MCProtocol::NumberSchema.new("number", description: "A decimal field")
      schema.type.should eq("number")
      schema.description.should eq("A decimal field")
    end

    it "validates schema type" do
      expect_raises(ArgumentError, "NumberSchema type must be 'integer' or 'number'") do
        MCProtocol::NumberSchema.new("string")
      end
    end

    it "serializes to correct JSON" do
      schema = MCProtocol::NumberSchema.new("integer", minimum: 1, maximum: 10, title: "Count")
      json = schema.to_json
      json.should contain("\"type\":\"integer\"")
      json.should contain("\"minimum\":1")
      json.should contain("\"maximum\":10")
      json.should contain("\"title\":\"Count\"")
    end
  end

  describe MCProtocol::StringSchema do
    it "creates basic string schema" do
      schema = MCProtocol::StringSchema.new
      schema.type.should eq("string")
      schema.format.should be_nil
    end

    it "creates string schema with format validation" do
      schema = MCProtocol::StringSchema.new(format: "email", min_length: 5, max_length: 100)
      schema.format.should eq("email")
      schema.min_length.should eq(5)
      schema.max_length.should eq(100)
    end

    it "validates format types" do
      expect_raises(ArgumentError, "StringSchema format must be one of: date, date-time, email, uri") do
        MCProtocol::StringSchema.new(format: "invalid")
      end
    end

    it "allows valid format types" do
      ["date", "date-time", "email", "uri"].each do |format|
        schema = MCProtocol::StringSchema.new(format: format)
        schema.format.should eq(format)
      end
    end
  end

  describe MCProtocol::EnumSchema do
    it "creates enum schema with values" do
      values = ["red", "green", "blue"]
      schema = MCProtocol::EnumSchema.new(values)
      schema.type.should eq("string")
      schema.enum.should eq(values)
      schema.enum_names.should be_nil
    end

    it "creates enum schema with names" do
      values = ["red", "green", "blue"]
      names = ["Red Color", "Green Color", "Blue Color"]
      schema = MCProtocol::EnumSchema.new(values, enum_names: names)
      schema.enum.should eq(values)
      schema.enum_names.should eq(names)
    end

    it "validates enum names array size" do
      expect_raises(ArgumentError, "EnumSchema enumNames array must match the size of enum array") do
        MCProtocol::EnumSchema.new(["a", "b"], enum_names: ["Name A"])
      end
    end

    it "serializes to correct JSON" do
      schema = MCProtocol::EnumSchema.new(["option1", "option2"], description: "Choose one")
      json = schema.to_json
      json.should contain("\"type\":\"string\"")
      json.should contain("\"enum\":[\"option1\",\"option2\"]")
      json.should contain("\"description\":\"Choose one\"")
    end
  end

  describe MCProtocol::PrimitiveSchemaDefinition do
    it "accepts all primitive schema types" do
      boolean_schema = MCProtocol::BooleanSchema.new
      number_schema = MCProtocol::NumberSchema.new("integer")
      string_schema = MCProtocol::StringSchema.new
      enum_schema = MCProtocol::EnumSchema.new(["a", "b"])

      # Test that they can all be used as PrimitiveSchemaDefinition
      schemas = [boolean_schema, number_schema, string_schema, enum_schema] of MCProtocol::PrimitiveSchemaDefinition
      schemas.size.should eq(4)
    end
  end
end 