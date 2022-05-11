class CustomDomainForm
  class HostUniquenessValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      scope = options.fetch(:scope) { CustomDomain.verified }
      return unless scope.exists?(host: value)

      record.errors.add(attribute, options.fetch(:message, :taken))
    end
  end

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :dashboard_host, HostnameType.new
  attribute :api_host, HostnameType.new
  attribute :mail_host, HostnameType.new

  delegate :persisted?, :id, to: :carrier

  validates :dashboard_host,
            presence: true,
            hostname: true,
            host_uniqueness: true

  validates :api_host,
            presence: true,
            hostname: true,
            host_uniqueness: true

  validates :mail_host,
            presence: true,
            hostname: true,
            host_uniqueness: true

  validate :validate_hosts

  def self.model_name
    ActiveModel::Name.new(self, nil, "CustomDomain")
  end

  def self.initialize_with(carrier)
    new(carrier:)
  end

  def save
    return false if invalid?

    CustomDomain.transaction do
      configure_custom_domain!(:dashboard, host: dashboard_host)
      configure_custom_domain!(:api, host: api_host)
      configure_custom_domain!(:mail, host: mail_host, verify_with: VerifyMailIdentityJob)
    end

    true
  end

  private

  def configure_custom_domain!(type, host:, verify_with: VerifyCustomDomainJob)
    domain = CustomDomain.create!(
      carrier:,
      type:,
      host:,
      verification_started_at: Time.current
    )
    verify_with.perform_later(domain)
  end

  def validate_hosts
    hosts = { mail_host:, api_host:, dashboard_host: }.compact
    duplicate_host = hosts.find { |_key, host| hosts.values.count(host) > 1 }
    return if duplicate_host.blank?

    errors.add(duplicate_host[0], :other_than, count: duplicate_host[1])
  end
end
