require "digest"

module CallService
  class Client
    attr_reader :default_host, :default_region, :username, :password, :queue_url, :subscriber_realm, :http_client, :sqs_client

    def initialize(**options)
      @default_host = options.fetch(:default_host) { CallService.configuration.default_host }
      @default_region = options.fetch(:default_region) { CallService.configuration.default_region }
      @username = options.fetch(:username) { CallService.configuration.username }
      @password = options.fetch(:password) { CallService.configuration.password }
      @queue_url = options.fetch(:queue_url) { CallService.configuration.queue_url }
      @subscriber_realm = options.fetch(:subscriber_realm) { CallService.configuration.subscriber_realm }
      @http_client = options.fetch(:http_client) { default_http_client }
      @sqs_client = options.fetch(:sqs_client) { Aws::SQS::Client.new }
    end

    def create_call(region: default_region, **params)
      base_url = default_host.gsub(default_region, region.to_s)
      execute_request(:post, "#{base_url}/calls", params)
    end

    def end_call(id:, host:)
      execute_request(:delete, "http://#{host}/calls/#{id}")
    end

    def update_call(id:, host:, **params)
      execute_request(:patch, "http://#{host}/calls/#{id}", params)
    end

    def create_subscriber(username:, password:)
      input = "#{username}:#{subscriber_realm}:#{password}"

      md5_password = Digest::MD5.hexdigest(input).first(32)
      sha256_password = Digest::SHA256.hexdigest(input).first(64)
      sha512_password = Digest::SHA512.hexdigest(input).first(64)

      enqueue_job(
        "CreateOpenSIPSSubscriberJob",
        username:,
        md5_password:,
        sha256_password:,
        sha512_password:
      )
    end

    def delete_subscriber(username:)
      enqueue_job("DeleteOpenSIPSSubscriberJob", username:)
    end

    def add_permission(*)
      enqueue_job("CreateOpenSIPSPermissionJob", *)
    end

    def update_permission(*)
      enqueue_job("UpdateOpenSIPSPermissionJob", *)
    end

    def remove_permission(*)
      enqueue_job("DeleteOpenSIPSPermissionJob", *)
    end

    private

    def execute_request(http_method, url, params = {}, headers = {})
      response = http_client.run_request(http_method, url, params.to_json, headers)

      Response.new(response)
    end

    def default_http_client
      Faraday.new(url: default_host) do |conn|
        conn.headers["Accept"] = "application/json"
        conn.headers["Content-Type"] = "application/json"

        conn.adapter Faraday.default_adapter

        conn.request(
          :authorization,
          :basic,
          username,
          password
        )
      end
    end

    def enqueue_job(job_class, *args)
      sqs_client.send_message(
        queue_url:,
        message_body: {
          job_class:,
          job_args: args
        }.to_json
      )
    end
  end
end
