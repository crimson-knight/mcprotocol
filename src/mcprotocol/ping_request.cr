module MCProtocol
  # A ping, issued by either the server or the client, to check that the other party is still alive. The receiver must promptly respond, or else may be disconnected.
  class PingRequest
    include JSON::Serializable
    getter method : String = "ping"
    getter params : JSON::Any?

    def initialize(@params : JSON::Any? = nil)
    end
  end
end
