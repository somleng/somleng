class ForgotSubdomainForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email

  validates :email, presence: true
  validate :validate_email_exists

  def self.model_name
    ActiveModel::Name.new(self, nil, "User")
  end

  def save
    return false if invalid?

    carriers = Carrier.joins(:carrier_users).where(users: { email: })
    ForgotSubdomainMailer.forgot_subdomain(email:, carriers:).deliver_later

    true
  end

  private

  def validate_email_exists
    errors.add(:email, :not_found) unless User.carrier.exists?(email:)
  end
end
