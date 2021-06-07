class UserForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  extend Enumerize

  attribute :name
  attribute :email
  attribute :role
  attribute :user
  attribute :carrier
  attribute :inviter

  enumerize :role, in: User.carrier_role.values, presence: true
  validates :name, :email, presence: true, unless: :persisted?
  validate :validate_email

  delegate :persisted?, :id, to: :user

  def self.model_name
    ActiveModel::Name.new(self, nil, "User")
  end

  def self.initialize_with(user)
    new(
      user: user,
      carrier: user.carrier,
      name: user.name,
      email: user.email,
      role: user.carrier_role
    )
  end

  def save
    return false if invalid?
    return user.update!(carrier_role: role) if persisted?

    User.invite!(
      {
        name: name,
        email: email,
        carrier_role: role,
        carrier: carrier
      },
      inviter
    )
  end

  private

  def validate_email
    errors.add(:email, :taken) if User.exists?(email: email)
  end
end
