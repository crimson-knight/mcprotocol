require "./spec_helper"

describe "Foundation Types" do
  describe MCProtocol::BaseMetadata do
    it "creates metadata with name only" do
      metadata = MCProtocol::BaseMetadata.new("my-identifier")
      metadata.name.should eq("my-identifier")
      metadata.title.should be_nil
    end

    it "creates metadata with name and title" do
      metadata = MCProtocol::BaseMetadata.new("api-endpoint", "API Endpoint")
      metadata.name.should eq("api-endpoint")
      metadata.title.should eq("API Endpoint")
    end

    it "serializes to correct JSON" do
      metadata = MCProtocol::BaseMetadata.new("user-profile", "User Profile")
      json = metadata.to_json
      json.should contain("\"name\":\"user-profile\"")
      json.should contain("\"title\":\"User Profile\"")
    end

    it "deserializes from JSON correctly" do
      json = %(
        {
          "name": "database-config",
          "title": "Database Configuration"
        }
      )

      metadata = MCProtocol::BaseMetadata.from_json(json)
      metadata.name.should eq("database-config")
      metadata.title.should eq("Database Configuration")
    end

    it "handles missing title field" do
      json = %({"name": "simple-name"})
      metadata = MCProtocol::BaseMetadata.from_json(json)
      metadata.name.should eq("simple-name")
      metadata.title.should be_nil
    end
  end

  describe MCProtocol::ClientCapabilities do
    it "creates capabilities with elicitation support" do
      elicitation_capability = JSON::Any.new({} of String => JSON::Any)
      capabilities = MCProtocol::ClientCapabilities.new(elicitation: elicitation_capability)
      
      capabilities.elicitation.should_not be_nil
      capabilities.experimental.should be_nil
      capabilities.roots.should be_nil
      capabilities.sampling.should be_nil
    end

    it "creates capabilities with all features" do
      elicitation = JSON::Any.new({} of String => JSON::Any)
      experimental = JSON::Any.new({"custom_feature" => JSON::Any.new(true)})
      roots = MCProtocol::ClientCapabilitiesRoots.new(listChanged: true)
      sampling = JSON::Any.new({} of String => JSON::Any)

      capabilities = MCProtocol::ClientCapabilities.new(
        elicitation: elicitation,
        experimental: experimental,
        roots: roots,
        sampling: sampling
      )

      capabilities.elicitation.should_not be_nil
      capabilities.experimental.should_not be_nil
      capabilities.roots.should_not be_nil
      capabilities.sampling.should_not be_nil
    end

    it "serializes to correct JSON with elicitation" do
      elicitation = JSON::Any.new({} of String => JSON::Any)
      capabilities = MCProtocol::ClientCapabilities.new(elicitation: elicitation)
      
      json = capabilities.to_json
      json.should contain("\"elicitation\":")
    end

    it "deserializes from JSON with elicitation" do
      json = %(
        {
          "elicitation": {},
          "experimental": {"feature1": true},
          "roots": {"listChanged": true},
          "sampling": {}
        }
      )

      capabilities = MCProtocol::ClientCapabilities.from_json(json)
      capabilities.elicitation.should_not be_nil
      capabilities.experimental.should_not be_nil
      capabilities.roots.should_not be_nil
      capabilities.sampling.should_not be_nil
    end
  end

  describe "Union Type Updates" do
    describe MCProtocol::ServerRequest do
             it "includes ElicitRequest in union" do
         properties = Hash(String, MCProtocol::PrimitiveSchemaDefinition).new
         properties["test"] = MCProtocol::StringSchema.new
        schema = MCProtocol::ElicitRequestSchema.new(properties)
        params = MCProtocol::ElicitRequestParams.new("Test message", schema)
        elicit_request = MCProtocol::ElicitRequest.new(params)

                 # Test that ElicitRequest can be used as ServerRequest
         server_request = elicit_request.as(MCProtocol::ServerRequest)
        
        case server_request
        when MCProtocol::ElicitRequest
          server_request.method.should eq("elicitation/create")
        else
          fail "Expected ElicitRequest in ServerRequest union"
        end
      end
    end

    describe MCProtocol::ClientResult do
      it "includes ElicitResult in union" do
        elicit_result = MCProtocol::ElicitResult.new("accept", {"test" => "value"} of String => String | Int32 | Bool)

                 # Test that ElicitResult can be used as ClientResult
         client_result = elicit_result.as(MCProtocol::ClientResult)

        case client_result
        when MCProtocol::ElicitResult
          client_result.action.should eq("accept")
        else
          fail "Expected ElicitResult in ClientResult union"
        end
      end
    end
  end

  describe "Naming Pattern Validation" do
    it "demonstrates programmatic vs display naming pattern" do
      # Test the BaseMetadata pattern that will be applied to many types
      
      # Programmatic name - used by code
      programmatic = MCProtocol::BaseMetadata.new("user_authentication_service")
      programmatic.name.should eq("user_authentication_service")
      programmatic.title.should be_nil
      
      # Display name - shown to users
      display = MCProtocol::BaseMetadata.new("user_authentication_service", "User Authentication Service")
      display.name.should eq("user_authentication_service")
      display.title.should eq("User Authentication Service")
      
      # The pattern: name for code, title for humans
      # If title is missing, name is used as fallback
    end

    it "validates ResourceLink follows naming pattern" do
      # ResourceLink implements the BaseMetadata pattern
      link = MCProtocol::ResourceLink.new(
        "user_data_csv", 
        "file:///data/users.csv",
        title: "User Data Spreadsheet"
      )
      
      # Programmatic identifier
      link.name.should eq("user_data_csv")
      # Human-readable display name
      link.title.should eq("User Data Spreadsheet")
    end
  end
end 