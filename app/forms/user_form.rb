class UserForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  extend Enumerize

  attribute :name
  attribute :email
  attribute :role
  attribute :user, default: -> { User.new }
  attribute :carrier
  attribute :inviter

  enumerize :role, in: User.carrier_role.values, presence: true
  validates :name, :email, presence: true, unless: :persisted?
  validates :email, email_uniqueness: true, email_format: true, allow_nil: true, allow_blank: true

  delegate :persisted?, :id, to: :user

  def self.model_name
    ActiveModel::Name.new(self, nil, "User")
  end

  def self.initialize_with(user)
    new(
      user:,
      carrier: user.carrier,
      name: user.name,
      email: user.email,
      role: user.carrier_role
    )
  end

  def save
    return false if invalid?
    return user.update!(carrier_role: role) if persisted?

    self.user = User.invite!(
      {
        name:,
        email:,
        carrier:,
        carrier_role: role
      },
      inviter
    )

    true
  end
end
