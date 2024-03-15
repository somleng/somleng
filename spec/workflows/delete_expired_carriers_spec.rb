require "rails_helper"

RSpec.describe DeleteExpiredCarriers do
  it "deletes expired carriers" do
    expired_user = create_carrier_owner(created_at: 7.days.ago)
    new_user = create_carrier_owner(created_at: Time.current)
    confirmed_user = create_carrier_owner(created_at: 7.days.ago, confirmed_at: Time.current)
    invited_owner = create_carrier_owner(created_at: 7.days.ago, invitation_created_at: 7.days.ago)

    carrier_with_multiple_owners = create(:carrier)
    owner_1 = create_carrier_owner(carrier: carrier_with_multiple_owners, created_at: 10.days.ago, confirmed_at: 10.days.ago)
    owner_2 = create_carrier_owner(carrier: carrier_with_multiple_owners, created_at: 7.days.ago, invitation_created_at: 7.days.ago)

    DeleteExpiredCarriers.call

    expect(User.find_by(id: expired_user.id)).to eq(nil)
    expect(Carrier.find_by(id: expired_user.carrier_id)).to eq(nil)
    expect(Doorkeeper::Application.find_by(id: expired_user.carrier.oauth_application.id)).to eq(nil)
    expect(Doorkeeper::AccessToken.find_by(token: expired_user.carrier.api_key)).to eq(nil)

    expect(User.find_by(id: new_user.id)).to eq(new_user)
    expect(User.find_by(id: confirmed_user.id)).to eq(confirmed_user)
    expect(User.find_by(id: owner_1.id)).to eq(owner_1)
    expect(User.find_by(id: owner_2.id)).to eq(owner_2)
  end

  def create_carrier_owner(**user_attributes)
    created_at = user_attributes.fetch(:created_at) { 7.days.ago }
    carrier = user_attributes.fetch(:carrier) { create(:carrier, created_at:) }
    user = create(
      :user,
      :carrier,
      carrier:,
      carrier_role: :owner,
      created_at:,
      sign_in_count: 0,
      confirmed_at: nil,
      invitation_created_at: nil,
      **user_attributes
    )
  end
end
