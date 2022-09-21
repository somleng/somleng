require "digest"

module CallService
  class Client
    attr_reader :http_client, :sqs_client

    def initialize(http_client: nil, sqs_client: Aws::SQS::Client.new)
      @http_client = http_client || default_http_client
      @sqs_client = sqs_client
    end

    def create_call(params)
      execute_request(:post, "/calls", params)
    end

    def end_call(id)
      execute_request(:delete, "/calls/#{id}")
    end

    def create_subscriber(username:, password:)
      input = "#{username}:#{CallService.configuration.subscriber_realm}:#{password}"

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

    def add_permission(ip)
      enqueue_job("CreateOpenSIPSPermissionJob", ip)
    end

    def remove_permission(ip)
      enqueue_job("DeleteOpenSIPSPermissionJob", ip)
    end

    private

    def execute_request(http_method, url, params = {}, headers = {})
      response = http_client.run_request(http_method, url, params.to_json, headers)

      Response.new(response)
    end

    def default_http_client
      Faraday.new(url: CallService.configuration.host) do |conn|
        conn.headers["Accept"] = "application/json"
        conn.headers["Content-Type"] = "application/json"

        conn.adapter Faraday.default_adapter

        conn.request(
          :authorization,
          :basic,
          CallService.configuration.username,
          CallService.configuration.password
        )
      end
    end

    def enqueue_job(job_class, *args)
      sqs_client.send_message(
        queue_url: CallService.configuration.queue_url,
        message_body: {
          job_class:,
          job_args: args
        }.to_json
      )
    end
  end
end
