# MCP Protocol Upgrade Implementation Instructions
## For Implementation Agent

---

## 🎯 **Mission Overview**

You are tasked with implementing the Model Context Protocol (MCP) upgrade from version **2025-03-26** to **2025-06-18**. This is a **major protocol update** that introduces significant new features including an elicitation system, enhanced metadata support, and improved type safety.

## 📋 **Primary Resources**

### **1. Implementation Tracker** 
- **File:** `MCP_UPGRADE_IMPLEMENTATION_TRACKER.md`
- **Purpose:** Your primary task management document
- **Contains:** 87 tracked tasks, priorities, dependencies, and progress monitoring
- **Update:** Check off tasks as you complete them

### **2. Schema References**
- **Old Schema:** `mcp_protocol_versions/2025_03_26/2025_03_26_schema.json`
- **New Schema:** `mcp_protocol_versions/2025_06_18/2025_06_18_schema.json`
- **Purpose:** Compare these to understand structural changes

### **3. Current Implementation**
- **Directory:** `src/mcprotocol/`
- **Files:** 80+ Crystal files implementing current protocol
- **Pattern:** Each type has its own `.cr` file (e.g., `tool.cr`, `resource.cr`)

---

## 🚀 **Getting Started - Phase 1: Foundation**

### **Step 1: Review Current State**
```bash
# Examine current file structure
ls -la src/mcprotocol/

# Check current implementation patterns
head -20 src/mcprotocol/tool.cr
head -20 src/mcprotocol/resource.cr
```

### **Step 2: Create Foundation Types**

**Start with these files in this exact order:**

1. **`src/mcprotocol/base_metadata.cr`** - Core foundation
   ```crystal
   # Base interface for metadata with name/title pattern
   # Fields: name (required), title (optional)
   # See new schema for exact structure
   ```

2. **Schema Definition Types** (create all before using):
   - `src/mcprotocol/boolean_schema.cr`
   - `src/mcprotocol/number_schema.cr` 
   - `src/mcprotocol/string_schema.cr`
   - `src/mcprotocol/enum_schema.cr`
   - `src/mcprotocol/primitive_schema_definition.cr` (union of above)

3. **Elicitation System**:
   - `src/mcprotocol/elicit_request.cr`
   - `src/mcprotocol/elicit_result.cr`

### **Step 3: Update Method Registration**
Update `src/mcprotocol.cr` to add:
```crystal
"elicitation/create" => {
  ElicitRequest, ElicitResult, ElicitRequestParams,
},
```

---

## 📐 **Implementation Patterns**

### **Crystal File Structure**
Follow existing patterns in the codebase:

```crystal
require "json"

module MCProtocol
  # JSON mapping with proper field types
  # Use @[JSON::Field] annotations for custom names
  # Include proper descriptions and validations
end
```

### **Key Patterns to Follow**

#### **1. JSON Field Mapping**
```crystal
@[JSON::Field(key: "fieldName")]
property field_name : Type
```

#### **2. Optional Fields**
```crystal
@[JSON::Field(key: "optionalField")]
property optional_field : Type?
```

#### **3. Union Types** 
```crystal
alias ContentBlock = TextContent | ImageContent | AudioContent | ResourceLink | EmbeddedResource
```

#### **4. Meta Fields**
All types getting `_meta` should follow this pattern:
```crystal
@[JSON::Field(key: "_meta")]
property meta : Hash(String, JSON::Any)?
```

---

## 🔧 **Technical Implementation Guidelines**

### **Priority 1: Core Infrastructure (Week 1-2)**

**HIGH Priority Tasks (Must Complete First):**
1. ✅ **Schema Definition System** - Foundation for elicitation
2. ✅ **Elicitation System** - New server-to-client communication  
3. ✅ **BaseMetadata Pattern** - Consistent naming across types
4. ✅ **Content Block Updates** - New ResourceLink content type

### **Priority 2: Metadata Enhancement (Week 2-3)**

**Add `_meta` fields to these files:**
- `audio_content.cr`, `blob_resource_contents.cr`, `embedded_resource.cr`
- `image_content.cr`, `text_content.cr`, `text_resource_contents.cr`
- `resource_contents.cr`, `resource.cr`, `resource_template.cr`
- `root.cr`, `tool.cr`, `prompt.cr`

**Pattern for _meta additions:**
```crystal
# Add this field to each class
@[JSON::Field(key: "_meta", description: "See [specification/2025-06-18/basic/index#general-fields] for notes on _meta usage.")]
property meta : Hash(String, JSON::Any)?
```

### **Priority 3: System Updates (Week 3-4)**

**Key Updates:**
- **CallToolResult**: Add `structuredContent` field
- **Tool**: Add `outputSchema` field  
- **Annotations**: Add `lastModified` field
- **CompleteRequest**: Add `context` field, update reference type

---

## ⚠️ **Critical Implementation Notes**

### **Breaking Changes to Handle**
1. **Content Types**: `PromptMessage.content` changes from union to `ContentBlock`
2. **Reference Types**: `CompleteRequest.ref` changes from `ResourceReference` to `ResourceTemplateReference`
3. **Tool Results**: `CallToolResult.content` now uses `ContentBlock` items
4. **JSON-RPC**: Simplified message union (remove batch arrays)

### **Dependency Management**
**CRITICAL:** Follow this dependency order:
```
base_metadata.cr → All BaseMetadata updates
All schema types → primitive_schema_definition.cr → elicit_request.cr  
resource_link.cr → content_block.cr → prompt_message.cr
elicit_request.cr + elicit_result.cr → server_request.cr + client_result.cr
```

### **Testing Strategy**
After each major component:
```bash
# Compile test
crystal build src/mcprotocol.cr

# Run existing specs  
crystal spec

# Test JSON parsing
crystal run examples/basic_server.cr
```

---

## 📊 **Progress Tracking**

### **Update the Tracker**
As you complete each task:
1. Open `MCP_UPGRADE_IMPLEMENTATION_TRACKER.md`
2. Change `- [ ]` to `- [x]` for completed tasks
3. Update progress percentages in the summary section
4. Add notes about any challenges or deviations

### **Commit Strategy**
**Commit frequently with descriptive messages:**
```bash
# Example commits
git add src/mcprotocol/base_metadata.cr
git commit -m "Add BaseMetadata foundation type

- Implements name/title pattern for consistent metadata
- Required by all updated types in 2025-06-18 spec
- Foundation for UI vs programmatic naming"

git add src/mcprotocol/*_schema.cr
git commit -m "Implement schema definition system

- Add boolean, number, string, enum schema types
- Create primitive schema definition union
- Required for elicitation form validation"
```

---

## 🆘 **When You Need Help**

### **Common Issues & Solutions**

#### **1. Type Compilation Errors**
- Check that all required dependencies are implemented first
- Verify JSON field mappings match schema exactly
- Ensure union types include all required variants

#### **2. Schema Validation Questions**
- Reference the JSON schema files for exact field requirements
- All new schema types must validate against primitive restrictions
- Elicitation schemas only allow top-level properties (no nesting)

#### **3. Breaking Change Conflicts**
- Update all usages of changed types consistently
- Test against existing examples to ensure compatibility
- Document any unavoidable breaking changes

### **Getting Unstuck**
If you encounter blockers:
1. **Check the tracker** - Look for dependency requirements
2. **Reference schemas** - Compare old vs new for clarity
3. **Follow patterns** - Look at existing similar implementations
4. **Test incrementally** - Compile after each major change

---

## ✅ **Success Criteria**

### **Phase 1 Complete When:**
- [ ] All schema definition types compile successfully  
- [ ] BaseMetadata pattern implemented and working
- [ ] Elicitation request/result types created
- [ ] Basic JSON parsing works for new types

### **Phase 2 Complete When:**
- [ ] All `_meta` fields added without breaking existing functionality
- [ ] Content block system updated with ResourceLink support
- [ ] Method registration includes elicitation endpoints

### **Phase 3 Complete When:**
- [ ] All existing tests pass with new implementation
- [ ] New elicitation workflow can be demonstrated
- [ ] Documentation updated with new features

### **Final Success:**
- [ ] Complete protocol upgrade implemented
- [ ] Backward compatibility maintained where possible  
- [ ] All 87 tasks in tracker completed
- [ ] Ready for production use

---

## 🎯 **Your First Tasks**

**Start Here (Next 2-3 Hours):**

1. **Review the codebase structure**
   ```bash
   find src/mcprotocol -name "*.cr" | head -10 | xargs head -5
   ```

2. **Create `base_metadata.cr`** - This is your foundation
   
3. **Implement `boolean_schema.cr`** - Simplest schema type to start

4. **Test compilation**
   ```bash
   crystal build src/mcprotocol.cr
   ```

5. **Update tracker** - Mark your first tasks complete

6. **Continue with remaining schema types**

---

## 📚 **Additional Context**

This upgrade represents a **significant enhancement** to the MCP protocol. The elicitation system enables servers to request structured input from users through the client, while the enhanced metadata support provides better UI/UX capabilities.

**Take your time** with the foundation types - they're used throughout the system. **Test frequently** to catch issues early. **Follow the tracker religiously** - it will keep you organized and on track.

**You've got this!** The analysis and planning are complete. Now it's time to implement. 🚀

---

*Document Version: 1.0*  
*Created for MCP Protocol Upgrade Implementation* 