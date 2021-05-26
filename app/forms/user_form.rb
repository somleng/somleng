class UserForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  extend Enumerize

  attribute :name
  attribute :email
  attribute :role
  attribute :id

  validates :name, :email, presence: true
  validate :validate_email

  enumerize :role, in: User.role.values

  def invite!(inviter)
    return resend_invite!(inviter) if id.present?
    return self if invalid?

    User.invite!(
      {
        name: name,
        email: email,
        role: role,
        carrier: inviter.carrier
      },
      inviter
    )
  end

  private

  def resend_invite!(inviter)
    user = inviter.carrier.users.find(id)
    user.invite!
    user
  end

  def validate_email
    errors.add(:email, :taken) if User.exists?(email: email)
  end
end
