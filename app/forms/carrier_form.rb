class CarrierForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  RESTRICTED_SUBDOMAINS = %w[
    api mail scfm docs dashboard switch somleng
  ].freeze

  class SubdomainUniquenessValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return unless Carrier.exists?(subdomain: value)

      record.errors.add(attribute, options.fetch(:message, :taken))
    end
  end

  attribute :company
  attribute :name
  attribute :work_email
  attribute :country
  attribute :subdomain, SubdomainType.new
  attribute :website
  attribute :password
  attribute :password_confirmation
  attribute :user, default: -> { User.new }

  validates :name,
            :work_email,
            :website,
            :company,
            :subdomain,
            :country,
            :password,
            :password_confirmation,
            presence: true

  validates :work_email, email_format: true, email_uniqueness: true, allow_blank: true
  validates :country, inclusion: { in: ISO3166::Country.all.map(&:alpha2) }
  validates :website, url_format: { allow_http: true }, allow_blank: true
  validates :password, confirmation: true
  validates :subdomain, subdomain_uniqueness: true, exclusion: RESTRICTED_SUBDOMAINS

  delegate :persisted?, to: :user

  def self.model_name
    ActiveModel::Name.new(self, nil, "Carrier")
  end

  def save
    return false if invalid?

    carrier = OnboardCarrier.call(
      name: company,
      country_code: country,
      website:,
      subdomain:,
      restricted: true,
      owner: {
        name:,
        password:,
        email: work_email
      }
    )

    self.user = carrier.carrier_users.first

    true
  end
end
