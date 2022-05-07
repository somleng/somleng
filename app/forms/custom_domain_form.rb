class CustomDomainForm
  class HostUniquenessValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      scope = options.fetch(:scope) { CustomDomain.verified }
      return if options[:unless] && options.fetch(:unless).call(record)

      return unless scope.exists?(host: value)

      record.errors.add(attribute, options.fetch(:message, :taken))
    end
  end

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :dashboard_host, HostnameType.new
  attribute :api_host, HostnameType.new

  delegate :persisted?, :id, to: :carrier

  validates :dashboard_host,
            presence: true,
            hostname: true,
            host_uniqueness: {
              unless: proc { |f| f.dashboard_host == f.carrier&.custom_domain(:dashboard)&.host }
            }

  validates :api_host,
            presence: true,
            hostname: true,
            comparison: { other_than: :dashboard_host },
            host_uniqueness: {
              unless: proc { |f| f.api_host == f.carrier&.custom_domain(:api)&.host }
            }

  def self.model_name
    ActiveModel::Name.new(self, nil, "CustomDomain")
  end

  def self.initialize_with(carrier)
    new(
      carrier:,
      dashboard_host: carrier.custom_domain(:dashboard)&.host,
      api_host: carrier.custom_domain(:api)&.host
    )
  end

  def save
    return false if invalid?

    CustomDomain.transaction do
      configure_custom_domain!(:dashboard, host: dashboard_host)
      configure_custom_domain!(:api, host: api_host)
    end

    true
  end

  private

  def configure_custom_domain!(type, host:)
    domain = carrier.custom_domain(type) || CustomDomain.new(carrier:, type:)
    domain.host = host

    return unless domain.host_changed?

    domain.regenerate_verification_token
    domain.verification_started_at = Time.current
    domain.verified_at = nil
    domain.save!
    VerifyCustomDomainJob.perform_later(domain)
  end
end
