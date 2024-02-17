class DeleteExpiredCarriers < ApplicationWorkflow
  def call
    expired_users.each do |expired_user|
      next unless expired_user.carrier.carrier_users.one?

      expired_user.destroy!
      expired_user.carrier.destroy!
    end
  end

  private

  def expired_users
    User
    .where(carrier_role: :owner)
    .where(sign_in_count: 0)
    .where(created_at: ..7.days.ago)
    .where(confirmed_at: nil)
    .where(invitation_created_at: nil)
  end
end
