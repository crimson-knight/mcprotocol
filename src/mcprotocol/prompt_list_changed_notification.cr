module MCProtocol
  # An optional notification from the server to the client, informing it that the list of prompts it offers has changed. This may be issued by servers without any previous subscription from the client.
  class PromptListChangedNotification
    include JSON::Serializable
    getter method : String = "notifications/prompts/list_changed"
    getter params : JSON::Any?

    def initialize(@params : JSON::Any? = nil)
    end
  end
end
