require "json"
require "uri"
require "./mcprotocol/*"

# JSON converter for URI type
module MCProtocol::URIConverter
  def self.from_json(parser : JSON::PullParser) : URI
    URI.parse(parser.read_string)
  end

  def self.to_json(uri : URI, builder : JSON::Builder)
    builder.string(uri.to_s)
  end
end

module MCProtocol
  VERSION = "1.0.0"
  
  # MCP Protocol version constants
  PROTOCOL_VERSION = "2025-06-18"
  PREVIOUS_PROTOCOL_VERSION = "2025-03-26"
  SUPPORTED_PROTOCOL_VERSIONS = [PROTOCOL_VERSION, PREVIOUS_PROTOCOL_VERSION]

  # Hand-rolled
  METHOD_TYPES = {
    "initialize" => {
      InitializeRequest, InitializeResult, InitializeRequestParams,
    },
    "ping" => {
      PingRequest, Nil, JSON::Any?,
    },
    "resources/list" => {
      ListResourcesRequest, ListResourcesResult, ListResourcesRequestParams,
    },
    "resources/templates/list" => {
      ListResourceTemplatesRequest, ListResourcesResult, ListResourcesRequestParams,
    },
    "resources/read" => {
      ReadResourceRequest, ReadResourceResult, ReadResourceRequestParams,
    },
    "resources/subscribe" => {
      SubscribeRequest, Nil, SubscribeRequestParams,
    },
    "resources/unsubscribe" => {
      UnsubscribeRequest, Nil, UnsubscribeRequestParams,
    },
    "prompts/list" => {
      ListPromptsRequest, ListPromptsResult, ListPromptsRequestParams,
    },
    "prompts/get" => {
      GetPromptRequest, GetPromptResult, GetPromptRequestParams,
    },
    "tools/list" => {
      ListToolsRequest, ListToolsResult, ListToolsRequestParams,
    },
    "tools/call" => {
      CallToolRequest, CallToolResult, CallToolRequestParams,
    },
    "logging/setLevel" => {
      SetLevelRequest, Nil, SetLevelRequestParams,
    },
    "completion/complete" => {
      CompleteRequest, CompleteResult, CompleteRequestParams,
    },
    "notifications/cancelled" => {
      CancelledNotification, Nil, CancelledNotificationParams,
    },
    "sampling/createMessage" => {
      CreateMessageRequest, CreateMessageResult, CreateMessageRequestParams,
    },
    "notifications/initialized" => {
      InitializedNotification, Nil, JSON::Any?,
    },
    "notifications/message" => {
      LoggingMessageNotification, Nil, LoggingMessageNotificationParams,
    },
    "notifications/progress" => {
      ProgressNotification, Nil, ProgressNotificationParams,
    },
    "notifications/prompts/list_changed" => {
      PromptListChangedNotification, Nil, JSON::Any?,
    },
    "notifications/resources/list_changed" => {
      ResourceListChangedNotification, Nil, JSON::Any?,
    },
    "notifications/resources/updated" => {
      ResourceUpdatedNotification, Nil, ResourceUpdatedNotificationParams,
    },
    "notifications/roots/list_changed" => {
      RootsListChangedNotification, Nil, JSON::Any?,
    },
    "notifications/tools/list_changed" => {
      ToolListChangedNotification, Nil, JSON::Any?,
    },
    "elicitation/create" => {
      ElicitRequest, ElicitResult, JSON::Any?,
    },
  }

  class ParseError < Exception
  end

  class UnsupportedProtocolVersionError < Exception
  end

  # Protocol version negotiation helper
  def self.negotiate_protocol_version(requested_version : String?) : String
    return PROTOCOL_VERSION if requested_version.nil?
    
    if SUPPORTED_PROTOCOL_VERSIONS.includes?(requested_version)
      requested_version
    else
      raise UnsupportedProtocolVersionError.new("Unsupported protocol version: #{requested_version}. Supported versions: #{SUPPORTED_PROTOCOL_VERSIONS.join(", ")}")
    end
  end

  # Check if a feature is available in the given protocol version
  def self.feature_available?(feature : String, protocol_version : String = PROTOCOL_VERSION) : Bool
    case feature
    when "elicitation"
      protocol_version == PROTOCOL_VERSION
    when "meta_fields"
      protocol_version == PROTOCOL_VERSION  
    when "base_metadata_pattern"
      protocol_version == PROTOCOL_VERSION
    when "enhanced_tools"
      protocol_version == PROTOCOL_VERSION
    when "content_blocks"
      true # Available in both versions
    when "basic_protocol"
      true # Available in both versions
    else
      false
    end
  end

  # Enhanced message parser with protocol version support
  def self.parse_message(data : String, method : String? = nil, *, as obj_type = nil, protocol_version : String = PROTOCOL_VERSION) : ClientRequest
    json = JSON.parse(data)
    json_h = json.as_h

    if method.nil?
      method = json_h["method"]?.try(&.as_s) || nil
    end

    if obj_type
      # already have type
      # elsif json_h["result"]?.try(&.as_h?) || json_h["result"]?.try(&.as_a?)
      #   raise ParseError.new("Method cannot be nil (found result)") if method.nil?

      #   obj_type = METHOD_TYPES[method][1]
    elsif json_h["error"]?.try(&.as_h?)
      obj_type = JSONRPCError
    else
      raise ParseError.new("Method cannot be nil") if method.nil?

      # Check if method is available in the protocol version
      if method == "elicitation/create" && !feature_available?("elicitation", protocol_version)
        raise UnsupportedProtocolVersionError.new("Elicitation not supported in protocol version #{protocol_version}")
      end

      method_mapping = METHOD_TYPES[method]?
      raise ParseError.new("Unknown method: #{method}") if method_mapping.nil?
      
      obj_type = method_mapping[0]
    end

    obj_type.from_json(data).as(ClientRequest)
  end
end
