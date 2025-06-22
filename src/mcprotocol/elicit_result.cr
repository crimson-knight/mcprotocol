require "json"

module MCProtocol
  # The client's response to an elicitation request.
  class ElicitResult
    include JSON::Serializable

    # This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
    @[JSON::Field(key: "_meta", description: "See [specification/2025-06-18/basic/index#general-fields] for notes on _meta usage.")]
    getter meta : Hash(String, JSON::Any)?

    # The user action in response to the elicitation
    # - "accept": User submitted the form/confirmed the action
    # - "decline": User explicitly declined the action
    # - "cancel": User dismissed without making an explicit choice
    @[JSON::Field(key: "action")]
    getter action : String

    # The submitted form data, only present when action is "accept"
    # Contains values matching the requested schema
    @[JSON::Field(key: "content")]
    getter content : Hash(String, String | Int32 | Bool)?

    def initialize(@action : String, @content : Hash(String, String | Int32 | Bool)? = nil, @meta : Hash(String, JSON::Any)? = nil)
      unless ["accept", "decline", "cancel"].includes?(@action)
        raise ArgumentError.new("ElicitResult action must be 'accept', 'decline', or 'cancel'")
      end
    end
  end
end 