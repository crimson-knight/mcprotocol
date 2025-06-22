require "./spec_helper"

describe "Content Block System" do
  describe MCProtocol::ResourceLink do
    it "creates a basic resource link" do
      link = MCProtocol::ResourceLink.new("my-file", "file:///path/to/file.txt")
      link.name.should eq("my-file")
      link.uri.should eq("file:///path/to/file.txt")
      link.type.should eq("resource_link")
      link.title.should be_nil
      link.description.should be_nil
    end

    it "creates a resource link with all optional fields" do
      link = MCProtocol::ResourceLink.new(
        name: "config-file",
        uri: "file:///etc/config.json",
        description: "Main configuration file",
        mime_type: "application/json",
        size: 1024,
        title: "Configuration File"
      )

      link.name.should eq("config-file")
      link.uri.should eq("file:///etc/config.json")
      link.type.should eq("resource_link")
      link.title.should eq("Configuration File")
      link.description.should eq("Main configuration file")
      link.mime_type.should eq("application/json")
      link.size.should eq(1024)
    end

    it "serializes to correct JSON" do
      link = MCProtocol::ResourceLink.new(
        "readme",
        "file:///README.md",
        description: "Project documentation",
        title: "Read Me"
      )

      json = link.to_json
      json.should contain("\"type\":\"resource_link\"")
      json.should contain("\"name\":\"readme\"")
      json.should contain("\"uri\":\"file:///README.md\"")
      json.should contain("\"description\":\"Project documentation\"")
      json.should contain("\"title\":\"Read Me\"")
    end

    it "deserializes from JSON correctly" do
      json = %(
        {
          "type": "resource_link",
          "name": "data-file",
          "uri": "file:///data.csv",
          "title": "Data File",
          "description": "Contains user data",
          "mimeType": "text/csv",
          "size": 2048
        }
      )

      link = MCProtocol::ResourceLink.from_json(json)
      link.name.should eq("data-file")
      link.uri.should eq("file:///data.csv")
      link.type.should eq("resource_link")
      link.title.should eq("Data File")
      link.description.should eq("Contains user data")
      link.mime_type.should eq("text/csv")
      link.size.should eq(2048)
    end
  end

  describe MCProtocol::ContentBlock do
         it "accepts TextContent as ContentBlock" do
       text = MCProtocol::TextContent.new("Hello, world!")
       content_block = text.as(MCProtocol::ContentBlock)
      
      case content_block
      when MCProtocol::TextContent
        content_block.text.should eq("Hello, world!")
        content_block.type.should eq("text")
      else
        fail "Expected TextContent"
      end
    end

         it "accepts ResourceLink as ContentBlock" do
       link = MCProtocol::ResourceLink.new("test-file", "file:///test.txt")
       content_block = link.as(MCProtocol::ContentBlock)

      case content_block
      when MCProtocol::ResourceLink
        content_block.name.should eq("test-file")
        content_block.type.should eq("resource_link")
      else
        fail "Expected ResourceLink"
      end
    end

         it "accepts ImageContent as ContentBlock" do
       image = MCProtocol::ImageContent.new("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==", "image/png")
       content_block = image.as(MCProtocol::ContentBlock)

             case content_block
       when MCProtocol::ImageContent
         content_block.mimeType.should eq("image/png")
        content_block.type.should eq("image")
      else
        fail "Expected ImageContent"
      end
    end

    it "allows mixed content block arrays" do
      text = MCProtocol::TextContent.new("Here's a file:")
      link = MCProtocol::ResourceLink.new("example", "file:///example.txt", title: "Example File")
      
             content_blocks = [text.as(MCProtocol::ContentBlock), link.as(MCProtocol::ContentBlock)]
      content_blocks.size.should eq(2)

      # Verify we can process the mixed array
      content_blocks.each do |block|
        case block
        when MCProtocol::TextContent
          block.text.should eq("Here's a file:")
        when MCProtocol::ResourceLink
          block.name.should eq("example")
        end
      end
    end
  end

  describe MCProtocol::ResourceTemplateReference do
    it "creates a resource template reference" do
      ref = MCProtocol::ResourceTemplateReference.new("file:///path/to/{id}")
      ref.type.should eq("ref/resource")
      ref.uri.should eq("file:///path/to/{id}")
    end

    it "serializes to correct JSON" do
      ref = MCProtocol::ResourceTemplateReference.new("https://api.example.com/files/{file_id}")
      json = ref.to_json
      json.should contain("\"type\":\"ref/resource\"")
      json.should contain("\"uri\":\"https://api.example.com/files/{file_id}\"")
    end

    it "deserializes from JSON correctly" do
      json = %(
        {
          "type": "ref/resource",
          "uri": "file:///templates/{template_name}"
        }
      )

      ref = MCProtocol::ResourceTemplateReference.from_json(json)
      ref.type.should eq("ref/resource")
      ref.uri.should eq("file:///templates/{template_name}")
    end
  end

  describe "Integration: Content in Tool Results" do
    it "demonstrates mixed content in tool responses" do
      # Simulate a tool that returns both text and file references
      content_blocks = [] of MCProtocol::ContentBlock

      # Add explanatory text
      content_blocks << MCProtocol::TextContent.new("I found the following files:")

      # Add file references
      content_blocks << MCProtocol::ResourceLink.new(
        "config",
        "file:///app/config.json",
        description: "Application configuration",
        title: "Config File",
        mime_type: "application/json"
      )

      content_blocks << MCProtocol::ResourceLink.new(
        "logs",
        "file:///var/log/app.log",
        description: "Application logs",
        title: "Log File",
        mime_type: "text/plain"
      )

      # Add closing text
      content_blocks << MCProtocol::TextContent.new("These files contain the information you requested.")

      # Verify the structure
      content_blocks.size.should eq(4)
      content_blocks[0].should be_a(MCProtocol::TextContent)
      content_blocks[1].should be_a(MCProtocol::ResourceLink)
      content_blocks[2].should be_a(MCProtocol::ResourceLink)
      content_blocks[3].should be_a(MCProtocol::TextContent)

      # Test that we can serialize this mixed content
      json_array = content_blocks.map(&.to_json)
      json_array.size.should eq(4)
      json_array[1].should contain("resource_link")
      json_array[1].should contain("config.json")
    end
  end
end 