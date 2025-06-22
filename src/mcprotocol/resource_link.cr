require "json"
require "./annotated"

module MCProtocol
  # A resource that the server is capable of reading, included in a prompt or tool call result.
  #
  # Note: resource links returned by tools are not guaranteed to appear in the results of `resources/list` requests.
  class ResourceLink
    include JSON::Serializable

    # This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
    @[JSON::Field(key: "_meta", description: "See [specification/2025-06-18/basic/index#general-fields] for notes on _meta usage.")]
    getter meta : Hash(String, JSON::Any)?

    # Optional annotations for the client
    @[JSON::Field(key: "annotations")]
    getter annotations : AnnotatedAnnotations?

    # A description of what this resource represents.
    #
    # This can be used by clients to improve the LLM's understanding of available resources. It can be thought of like a "hint" to the model.
    @[JSON::Field(key: "description")]
    getter description : String?

    # The MIME type of this resource, if known
    @[JSON::Field(key: "mimeType")]
    getter mime_type : String?

    # Intended for programmatic or logical use, but used as a display name in past specs or fallback (if title isn't present)
    @[JSON::Field(key: "name")]
    getter name : String

    # The size of the raw resource content, in bytes (i.e., before base64 encoding or any tokenization), if known.
    #
    # This can be used by Hosts to display file sizes and estimate context window usage.
    @[JSON::Field(key: "size")]
    getter size : Int32?

    # Intended for UI and end-user contexts — optimized to be human-readable and easily understood,
    # even by those unfamiliar with domain-specific terminology.
    #
    # If not provided, the name should be used for display (except for Tool,
    # where `annotations.title` should be given precedence over using `name`,
    # if present).
    @[JSON::Field(key: "title")]
    getter title : String?

    # The type identifier for resource links
    @[JSON::Field(key: "type")]
    getter type : String = "resource_link"

    # The URI of this resource
    @[JSON::Field(key: "uri")]
    getter uri : String

    def initialize(@name : String, @uri : String, @description : String? = nil, @mime_type : String? = nil, @size : Int32? = nil, @title : String? = nil, @annotations : AnnotatedAnnotations? = nil, @meta : Hash(String, JSON::Any)? = nil)
    end
  end
end 