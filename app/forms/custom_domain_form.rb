class CustomDomainForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :dashboard_host, HostnameType.new
  attribute :api_host, HostnameType.new

  delegate :persisted?, :id, to: :carrier

  validates :dashboard_host, presence: true, hostname: true
  validates :api_host, presence: true, hostname: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "CustomDomain")
  end

  def self.initialize_with(carrier)
    new(
      carrier:,
      dashboard_host: carrier.custom_dashboard_domain&.host,
      api_host: carrier.custom_api_domain&.host
    )
  end

  def save
    return false if invalid?

    custom_dashboard_domain.host = dashboard_host
    custom_api_domain.host = api_host

    carrier.save!
    ExecuteWorkflowJob.perform_later(VerifyCustomDomain.to_s, custom_dashboard_domain)
    ExecuteWorkflowJob.perform_later(VerifyCustomDomain.to_s, custom_api_domain)

    true
  end

  private

  def custom_dashboard_domain
    @custom_dashboard_domain ||= carrier.custom_dashboard_domain || carrier.build_custom_dashboard_domain
  end

  def custom_api_domain
    @custom_api_domain ||= carrier.custom_api_domain || carrier.build_custom_api_domain
  end
end
