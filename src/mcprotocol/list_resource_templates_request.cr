module MCProtocol
  class ListResourceTemplatesRequestParams
    include JSON::Serializable
    # An opaque token representing the current pagination position.
    # If provided, the server should return results starting after this cursor.
    getter cursor : String?

    def initialize(@cursor : String? = nil)
    end
  end

  # Sent from the client to request a list of resource templates the server has.
  class ListResourceTemplatesRequest
    include JSON::Serializable
    getter method : String = "resources/templates/list"
    getter params : ListResourceTemplatesRequestParams?

    def initialize(@params : ListResourceTemplatesRequestParams? = nil)
    end
  end
end
