module CallService
  class Configuration
    attr_accessor :host, :username, :password, :subscriber_realm, :queue_url, :function_arn, :logger
  end
end
