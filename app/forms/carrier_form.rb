class CarrierForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  URL_FORMAT = /\A#{URI::DEFAULT_PARSER.make_regexp(%w[https http])}\z/

  attribute :company
  attribute :name
  attribute :work_email
  attribute :country
  attribute :website
  attribute :password
  attribute :password_confirmation
  attribute :user, default: -> { User.new }

  validates :name,
            :work_email,
            :website,
            :company,
            :country,
            :password,
            :password_confirmation,
            presence: true

  validates :work_email, email_format: true, email_uniqueness: true, allow_nil: true, allow_blank: true
  validates :country, inclusion: { in: ISO3166::Country.all.map(&:alpha2) }
  validates :website, format: URL_FORMAT, allow_blank: true
  validates :password, confirmation: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "Carrier")
  end

  def save
    return false if invalid?

    carrier = OnboardCarrier.call(
      name: company,
      country_code: country,
      owner: {
        name:,
        password:,
        email: work_email
      }
    )

    self.user = carrier.users.first

    true
  end
end
