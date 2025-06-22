# Breaking Changes: MCP Protocol Upgrade 2025-03-26 → 2025-06-18

## Overview

The Model Context Protocol (MCP) upgrade from version 2025-03-26 to 2025-06-18 introduces significant enhancements and some breaking changes. This document provides a comprehensive guide for developers upgrading their MCP implementations.

## 🚨 Critical Breaking Changes

### 1. Content Type System Changes
**Impact: HIGH - Affects all content handling**

#### PromptMessage Content Field
- **Before:** `content : TextContent | ImageContent | EmbeddedResource`
- **After:** `content : ContentBlock`
- **Migration:** Update all PromptMessage creation to use ContentBlock union type

#### CallToolResult Content Field  
- **Before:** `content : Array(String)`
- **After:** `content : Array(ContentBlock)`
- **Migration:** Wrap string content in TextContent blocks

### 2. Reference Type Changes
**Impact: MEDIUM - Affects completion requests**

#### CompleteRequest Reference Field
- **Before:** `ref : PromptReference | ResourceReference`
- **After:** `ref : PromptReference | ResourceTemplateReference`
- **Migration:** Update resource references to use ResourceTemplateReference

### 3. Field Additions with Required Constructor Updates
**Impact: MEDIUM - Affects object construction**

All types with `_meta` fields now require updated constructors:
- TextContent, ImageContent, EmbeddedResource
- BlobResourceContents, TextResourceContents, ResourceContents
- Resource, ResourceTemplate, Root, Tool, Prompt

**Migration:** Add `meta : Hash(String, JSON::Any)? = nil` parameter to constructors

## 🆕 New Features (Non-Breaking)

### 1. Elicitation System
**New server-to-client communication capability**

#### New Types Added:
- `ElicitRequest` - Server requests structured user input
- `ElicitResult` - Client responses with form data
- Schema definition system (BooleanSchema, NumberSchema, StringSchema, EnumSchema)

#### New Method:
- `"elicitation/create"` added to METHOD_TYPES

#### Client Capabilities Update:
- `elicitation` property added to ClientCapabilities

### 2. BaseMetadata Pattern
**Consistent naming across all entity types**

#### New Fields Added:
- `title : String?` added to: Implementation, Prompt, PromptArgument, PromptReference, Resource, ResourceTemplate, Tool
- All `name` field descriptions updated for programmatic vs UI clarity

### 3. Enhanced Tool Capabilities
#### New Tool Features:
- `outputSchema : JSON::Any?` - Define expected output format
- `structuredContent : JSON::Any?` in CallToolResult - Machine-readable output

### 4. Annotation Enhancements
#### New Annotation Field:
- `lastModified : String?` in AnnotatedAnnotations - ISO 8601 timestamps

### 5. Completion Context
#### New CompleteRequest Feature:
- `context : Hash(String, JSON::Any)?` - Additional completion context

## 📋 Migration Checklist

### For MCP Servers:
- [ ] Update PromptMessage content creation to use ContentBlock
- [ ] Update CallToolResult to return ContentBlock arrays instead of strings
- [ ] Add `_meta` parameter to all entity constructors 
- [ ] Implement elicitation support if desired (optional)
- [ ] Update resource references to use ResourceTemplateReference
- [ ] Add `title` fields to all metadata-capable types

### For MCP Clients:
- [ ] Update ClientCapabilities to include elicitation support if desired
- [ ] Handle new ContentBlock types in message parsing
- [ ] Update CompleteRequest to use ResourceTemplateReference
- [ ] Add support for tool outputSchema validation (optional)
- [ ] Handle structured content in tool results (optional)

### For Both:
- [ ] Update METHOD_TYPES to include "elicitation/create"
- [ ] Test JSON serialization/deserialization with new fields
- [ ] Update error handling for new request/result types
- [ ] Validate protocol version negotiation

## 🔧 Implementation Examples

### Content Block Migration
```crystal
# Before (2025-03-26)
message = PromptMessage.new(
  content: TextContent.new("Hello world"),
  role: Role::User
)

# After (2025-06-18) 
message = PromptMessage.new(
  content: TextContent.new("Hello world"),  # TextContent is now a ContentBlock
  role: Role::User
)
```

### Tool Result Migration
```crystal
# Before (2025-03-26)
result = CallToolResult.new(
  content: ["Operation completed successfully"]
)

# After (2025-06-18)
result = CallToolResult.new(
  content: [TextContent.new("Operation completed successfully")]
)
```

### Constructor Updates
```crystal
# Before (2025-03-26)
resource = Resource.new(
  name: "example.txt",
  uri: URI.parse("file:///example.txt")
)

# After (2025-06-18)
resource = Resource.new(
  name: "example.txt", 
  uri: URI.parse("file:///example.txt"),
  title: "Example Document",  # New optional field
  meta: {"source" => JSON::Any.new("user_upload")}  # New optional field
)
```

## 🔄 Backward Compatibility

### What's Preserved:
- All existing method names and core functionality
- JSON-RPC protocol structure
- Basic request/response patterns
- Core type interfaces

### What Requires Updates:
- Constructor calls with new optional parameters
- Content handling code
- Reference type handling in completion
- Method registration for elicitation

## ⚠️ Common Migration Issues

### 1. Constructor Parameter Order
**Problem:** New optional parameters added to constructors
**Solution:** Use named parameters when possible, or update parameter lists

### 2. Content Type Casting
**Problem:** ContentBlock union type may require explicit casting
**Solution:** Use `.as(SpecificType)` when needed for type safety

### 3. Missing Method Registration
**Problem:** Elicitation requests fail without proper method registration
**Solution:** Add "elicitation/create" to METHOD_TYPES hash

### 4. JSON Field Mapping
**Problem:** New fields may not serialize/deserialize correctly
**Solution:** Ensure all new fields have proper `@[JSON::Field]` annotations

## 🧪 Testing Your Migration

### Validation Steps:
1. **Compile Test:** Ensure all code compiles with new types
2. **JSON Test:** Verify serialization/deserialization of new fields
3. **Protocol Test:** Test complete request/response cycles
4. **Elicitation Test:** If implemented, test elicitation workflow
5. **Backward Compatibility Test:** Ensure old clients still work where possible

### Sample Test Cases:
```crystal
# Test new ContentBlock handling
content_block = TextContent.new("test", meta: {"test" => JSON::Any.new(true)})
json = content_block.to_json
parsed = TextContent.from_json(json)

# Test elicitation workflow
request = ElicitRequest.new(
  message: "Please provide your name",
  requestedSchema: StringSchema.new(description: "Your full name")
)
```

## 📞 Support and Resources

- **Protocol Documentation:** [MCP 2025-06-18 Specification]
- **Schema Reference:** `mcp_protocol_versions/2025_06_18/2025_06_18_schema.json`
- **Implementation Examples:** See `examples/` directory

## 📅 Migration Timeline Recommendations

### Phase 1 (Week 1): Core Updates
- Update constructors and type definitions
- Fix compilation errors
- Basic testing

### Phase 2 (Week 2): Feature Integration  
- Implement new content handling
- Add elicitation support (if desired)
- Enhanced testing

### Phase 3 (Week 3): Production Preparation
- Comprehensive testing
- Performance validation
- Documentation updates

---

*Last Updated: 2024-12-05*
*MCP Protocol Version: 2025-06-18* 