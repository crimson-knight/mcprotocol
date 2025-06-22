require "json"

module MCProtocol
  # A reference to a resource or resource template definition.
  class ResourceTemplateReference
    include JSON::Serializable

    # The type identifier for resource template references
    @[JSON::Field(key: "type")]
    getter type : String = "ref/resource"

    # The URI or URI template of the resource
    @[JSON::Field(key: "uri")]
    getter uri : String

    def initialize(@uri : String)
    end
  end
end 