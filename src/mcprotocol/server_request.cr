require "./elicit_request"

module MCProtocol
  alias ServerRequest = PingRequest | CreateMessageRequest | ListRootsRequest | ElicitRequest
end
