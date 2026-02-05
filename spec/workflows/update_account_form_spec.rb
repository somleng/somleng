require "rails_helper"

RSpec.describe UpdateAccountForm do
  it "updates an account form" do
    account = create(:account, :billing_enabled)
    existing_subscription = create(:tariff_plan_subscription, plan_category: :outbound_calls, account:)
    rating_engine_client = instance_spy(RatingEngineClient)
    form = build_form(
      account:,
      tariff_plan_subscriptions: [
        {
          id: existing_subscription.id,
          category: :outbound_calls,
          enabled: false,
          plan_id: existing_subscription.plan_id
        }
      ]
    )

    UpdateAccountForm.call(form, client: rating_engine_client)

    expect(rating_engine_client).to have_received(:upsert_account) do |account|
      expect(account.tariff_plan_subscriptions).to be_empty
    end
  end

  def build_form(account: create(:account), **params)
    form = AccountForm.initialize_with(account)
    form.attributes = params
    form
  end
end
