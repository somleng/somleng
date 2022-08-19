class InboundSIPTrunkAuthorization
  attr_reader :client

  def initialize(client: Aws::SQS::Client.new)
    @client = client
  end

  def add_permission(ip)
    enqueue_job("CreateOpenSIPSPermissionJob", ip)
  end

  def remove_permission(ip)
    enqueue_job("DeleteOpenSIPSPermissionJob", ip)
  end

  private

  def enqueue_job(job_class, ip)
    client.send_message(
      queue_url: AppSettings.config_for(:switch_services_queue_url),
      message_body: {
        job_class:,
        job_args: [ip]
      }.to_json
    )
  end
end
