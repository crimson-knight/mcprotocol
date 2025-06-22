# MCP Protocol Migration Script
## Automated Upgrade Assistance: 2025-03-26 → 2025-06-18

This script provides automated migration patterns and code transformations to help upgrade your MCP implementation from version 2025-03-26 to 2025-06-18.

## 🔧 Quick Start Migration Commands

### 1. Constructor Updates - Add Optional Parameters

**Pattern**: Add `meta` and `title` parameters to constructors

```bash
# Find all constructor calls that need updating
grep -r "\.new(" src/ | grep -E "(Resource|Tool|Prompt|TextContent|ImageContent)"

# Manual update required - add optional parameters:
# Before: Resource.new(name, uri)
# After:  Resource.new(name, uri, meta: nil, title: nil)
```

### 2. Content Block Migration

**Search Pattern**: Find PromptMessage and CallToolResult usage
```bash
# Find PromptMessage content assignments
grep -r "PromptMessage" src/ | grep "content.*="

# Find CallToolResult content arrays  
grep -r "CallToolResult" src/ | grep "content.*\["
```

**Replacement Pattern**:
```crystal
# PromptMessage - Usually no change needed (TextContent is ContentBlock)
# CallToolResult - Wrap strings in TextContent
# Before: content: ["Result text"]
# After:  content: [TextContent.new("Result text")]
```

### 3. Reference Type Updates

**Search Pattern**: Find CompleteRequest usage
```bash
grep -r "CompleteRequest" src/ | grep "ResourceReference"
```

**Replacement Pattern**:
```crystal
# Before: ref: ResourceReference.new(...)
# After:  ref: ResourceTemplateReference.new(...)
```

## 🔍 Automated Detection Scripts

### Crystal Migration Helper Script

```crystal
#!/usr/bin/env crystal

# migration_helper.cr
# Analyzes code for common migration patterns

require "file_utils"

class MigrationHelper
  def initialize(@source_dir : String)
  end

  def analyze
    puts "🔍 Analyzing MCP Migration Requirements..."
    puts ""
    
    check_constructor_usage
    check_content_block_usage  
    check_reference_usage
    check_method_registration
  end

  private def check_constructor_usage
    puts "📋 Constructor Usage Analysis:"
    
    types_to_check = [
      "Resource", "Tool", "Prompt", "TextContent", 
      "ImageContent", "EmbeddedResource", "ResourceTemplate"
    ]
    
    types_to_check.each do |type|
      files = find_constructor_usage(type)
      if files.any?
        puts "  ⚠️  #{type}.new() found in: #{files.join(", ")}"
        puts "      ↳ Add meta/title parameters as needed"
      else
        puts "  ✅ #{type} - No usage found"
      end
    end
    puts ""
  end

  private def check_content_block_usage
    puts "🔧 Content Block Usage Analysis:"
    
    # Check PromptMessage content
    prompt_files = find_pattern("PromptMessage.*content")
    if prompt_files.any?
      puts "  📝 PromptMessage content found in: #{prompt_files.join(", ")}"
      puts "      ↳ Verify ContentBlock compatibility"
    end
    
    # Check CallToolResult content
    result_files = find_pattern("CallToolResult.*content.*\\[")
    if result_files.any?
      puts "  ⚠️  CallToolResult string arrays found in: #{result_files.join(", ")}" 
      puts "      ↳ Wrap strings in TextContent.new()"
    end
    puts ""
  end

  private def check_reference_usage
    puts "🔗 Reference Type Analysis:"
    
    ref_files = find_pattern("ResourceReference")
    if ref_files.any?
      puts "  ⚠️  ResourceReference found in: #{ref_files.join(", ")}"
      puts "      ↳ Consider using ResourceTemplateReference for completion"
    else
      puts "  ✅ No ResourceReference usage found"
    end
    puts ""
  end

  private def check_method_registration
    puts "📡 Method Registration Analysis:"
    
    method_files = find_pattern("METHOD_TYPES.*=")
    if method_files.any?
      puts "  📝 METHOD_TYPES found in: #{method_files.join(", ")}"
      puts "      ↳ Add 'elicitation/create' method if using elicitation"
    end
    puts ""
  end

  private def find_constructor_usage(type : String) : Array(String)
    find_pattern("#{type}\\.new\\(")
  end

  private def find_pattern(pattern : String) : Array(String)
    files = [] of String
    
    Dir.glob("#{@source_dir}/**/*.cr") do |file|
      if File.read(file).match(/#{pattern}/)
        files << File.basename(file)
      end
    end
    
    files
  end
end

# Usage
if ARGV.size > 0
  analyzer = MigrationHelper.new(ARGV[0])
  analyzer.analyze
else
  puts "Usage: crystal migration_helper.cr <source_directory>"
  puts "Example: crystal migration_helper.cr src/"
end
```

## 📋 Checklist-Based Migration

### Phase 1: Type System Updates

```bash
# 1. Check compilation with new types
crystal build src/mcprotocol.cr

# 2. Update constructors systematically
# For each file that fails compilation:
#   - Add meta: Hash(String, JSON::Any)? = nil parameter
#   - Add title: String? = nil parameter (for named entities)

# 3. Update content handling
# Search for: CallToolResult.new(content: [...])
# Replace with: CallToolResult.new(content: [...].map { |s| TextContent.new(s) })
```

### Phase 2: Feature Integration

```bash
# 1. Add elicitation support (optional)
# Add to METHOD_TYPES:
# "elicitation/create" => {
#   ElicitRequest, ElicitResult, JSON::Any?,
# },

# 2. Update ClientCapabilities (if supporting elicitation)
# Add: elicitation: true

# 3. Test new features
crystal spec
```

### Phase 3: Production Validation

```bash
# 1. Integration testing
# Test complete request/response cycles

# 2. JSON serialization testing
# Ensure all new fields serialize/deserialize correctly

# 3. Backward compatibility testing
# Test with older client versions where possible
```

## 🔄 Semi-Automated Transformations

### Constructor Parameter Addition

**Find and Replace Patterns** (use with caution - manual review required):

```bash
# Resource constructors
find src/ -name "*.cr" -exec sed -i.bak 's/Resource\.new(\([^)]*\))/Resource.new(\1, meta: nil)/g' {} \;

# Tool constructors - more complex, manual update recommended
# Before: Tool.new(inputSchema, name, description)
# After:  Tool.new(inputSchema, name, description, title: nil, meta: nil)

# TextContent constructors
find src/ -name "*.cr" -exec sed -i.bak 's/TextContent\.new(\([^)]*\))/TextContent.new(\1, meta: nil)/g' {} \;
```

**⚠️ Warning**: Always backup files before running sed commands!

### Content Array Migration

```crystal
# Helper function for content array migration
def migrate_content_array(content_strings : Array(String)) : Array(ContentBlock)
  content_strings.map { |s| TextContent.new(s).as(ContentBlock) }
end

# Usage example:
# old_content = ["Result 1", "Result 2"]
# new_content = migrate_content_array(old_content)
# CallToolResult.new(content: new_content)
```

## 🧪 Validation Scripts

### Post-Migration Validation

```crystal
# validation_test.cr
# Run after migration to verify correctness

require "./src/mcprotocol"

# Test new type instantiation
puts "Testing new types..."

# Test schema types
schema = MCProtocol::StringSchema.new(
  description: "Test schema",
  title: "Test"
)
puts "✅ StringSchema: #{schema.to_json}"

# Test elicitation (if implemented)
begin
  request = MCProtocol::ElicitRequest.new(
    message: "Test elicitation",
    requestedSchema: schema
  )
  puts "✅ ElicitRequest: #{request.to_json}"
rescue
  puts "ℹ️  Elicitation not implemented - OK"
end

# Test content blocks
content = MCProtocol::TextContent.new("Test", meta: {"test" => JSON::Any.new(true)})
puts "✅ TextContent with meta: #{content.to_json}"

# Test resource with new fields
resource = MCProtocol::Resource.new(
  name: "test_resource",
  uri: URI.parse("file:///test"),
  title: "Test Resource",
  meta: {"migration" => JSON::Any.new("success")}
)
puts "✅ Resource with new fields: #{resource.to_json}"

puts ""
puts "🎉 Migration validation complete!"
```

## 📊 Migration Progress Tracking

### Migration Checklist Template

```markdown
## My MCP Migration Progress

### Core Type Updates
- [ ] Resource constructors updated
- [ ] Tool constructors updated  
- [ ] Prompt constructors updated
- [ ] Content type constructors updated
- [ ] All compilation errors resolved

### Content System Migration
- [ ] PromptMessage content verified
- [ ] CallToolResult content arrays converted
- [ ] ContentBlock types working correctly

### Feature Integration
- [ ] METHOD_TYPES updated with elicitation (if needed)
- [ ] ClientCapabilities updated (if supporting elicitation)
- [ ] Reference types updated (CompleteRequest)

### Testing & Validation
- [ ] All tests passing
- [ ] JSON serialization working
- [ ] Integration tests completed
- [ ] Backward compatibility verified (where applicable)

### Production Preparation
- [ ] Performance testing completed
- [ ] Documentation updated
- [ ] Breaking changes communicated to users
```

## 🆘 Common Issues and Solutions

### Issue 1: Constructor Compilation Errors
**Problem**: "Wrong number of arguments"
**Solution**: Add optional meta/title parameters to constructor calls

### Issue 2: ContentBlock Type Errors
**Problem**: "No overload matches"
**Solution**: Ensure string content is wrapped in TextContent.new()

### Issue 3: JSON Serialization Issues
**Problem**: New fields not serializing
**Solution**: Verify @[JSON::Field] annotations are present

### Issue 4: Method Not Found
**Problem**: "elicitation/create" method not recognized
**Solution**: Add method to METHOD_TYPES hash

## 📞 Migration Support

If you encounter issues not covered by this script:

1. **Check Breaking Changes**: Review `BREAKING_CHANGES.md` for detailed migration guidance
2. **Test Systematically**: Run `crystal build` and `crystal spec` frequently
3. **Validate JSON**: Test serialization/deserialization of new types
4. **Ask for Help**: Reference the MCP community forums or documentation

---

**Migration Script Version**: 1.0
**Target Protocol**: MCP 2025-06-18
**Last Updated**: 2024-12-05 