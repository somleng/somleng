require "rails_helper"

RSpec.describe RatingEngineClient do
  describe "#account_balance" do
    it "sends a request to get an account balance" do
      account = create(:account)
      client = instance_spy(CGRateS::Client)
      rating_engine_client = RatingEngineClient.new(client:)
      allow(client).to receive(:get_account).and_return(
        CGRateS::Response.new(id: 1, result: { "BalanceMap" => { "*monetary" => [ { "Value" => 100 } ] } })
      )

      balance = rating_engine_client.account_balance(account)

      expect(balance).to eq(Money.from_amount(100, account.billing_currency))
    end

    it "returns a zero balance if the account has no balance" do
      account = create(:account)
      client = instance_spy(CGRateS::Client)
      rating_engine_client = RatingEngineClient.new(client:)
      allow(client).to receive(:get_account).and_return(
        CGRateS::Response.new(id: 1, result: { "BalanceMap" => nil })
      )

      balance = rating_engine_client.account_balance(account)

      expect(balance).to eq(Money.from_amount(0, account.billing_currency))
    end
  end

  describe "#upsert_destination_group" do
    it "sends a request to upsert a destination group" do
      destination_group = create(:destination_group, prefixes: [ "855" ])
      client = instance_spy(CGRateS::Client)
      rating_engine_client = RatingEngineClient.new(client:)

      rating_engine_client.upsert_destination_group(destination_group)

      expect(client).to have_received(:set_tp_destination).with(
        tp_id: destination_group.carrier_id,
        id: destination_group.id,
        prefixes: [ "855" ]
      )
    end
  end

  describe "#upsert_tariff_schedule" do
    it "sends a request to upsert a tariff schedule" do
      carrier = create(:carrier, billing_currency: "USD")
      tariff_schedule = create(:tariff_schedule, :outbound_calls, carrier:)
      tariffs = [
        create(:tariff, :call, carrier:, rate_cents: InfinitePrecisionMoney.from_amount(0.005, "USD").cents),
        create(:tariff, :call, carrier:, rate_cents: InfinitePrecisionMoney.from_amount(0.001, "USD").cents)
      ]
      destination_tariffs = [
        create(:destination_tariff, schedule: tariff_schedule, tariff: tariffs[0]),
        create(:destination_tariff, schedule: tariff_schedule, tariff: tariffs[1])
      ]
      client = instance_spy(CGRateS::Client)
      rating_engine_client = RatingEngineClient.new(client:)

      rating_engine_client.upsert_tariff_schedule(tariff_schedule)

      expect(client).to have_received(:set_tp_rate).with(
        tp_id: carrier.id,
        id: tariffs[0].id,
        rate_slots: [
          { rate: 0.005, rate_unit: "60s", rate_increment: "60s" }
        ]
      )
      expect(client).to have_received(:set_tp_rate).with(
        tp_id: carrier.id,
        id: tariffs[1].id,
        rate_slots: [
          { rate: 0.001, rate_unit: "60s", rate_increment: "60s" }
        ]
      )
      expect(client).to have_received(:set_tp_destination_rate).with(
        tp_id: carrier.id,
        id: tariff_schedule.id,
        destination_rates: [
          {
            rounding_decimals: 4,
            rounding_method: "*up",
            rate_id: tariffs[0].id,
            destination_id: destination_tariffs[0].destination_group_id
          },
          hash_including(
            rate_id: tariffs[1].id,
            destination_id: destination_tariffs[1].destination_group_id,
          )
        ]
      )
    end
  end

  describe "#destroy_tariff_schedule" do
    it "sends a request to destroy a tariff schedule" do
      tariff_schedule = create(:tariff_schedule)
      client = instance_spy(CGRateS::Client)
      rating_engine_client = RatingEngineClient.new(client:)

      rating_engine_client.destroy_tariff_schedule(tariff_schedule)

      expect(client).to have_received(:remove_tp_destination_rate).with(
        tp_id: tariff_schedule.carrier_id,
        id: tariff_schedule.id,
      )
    end
  end

  describe "#upsert_tariff_plan" do
    it "sends a request to upsert a tariff plan" do
      tariff_plan = create(:tariff_plan)
      tiers = [
        create(:tariff_plan_tier, plan: tariff_plan, weight: 20),
        create(:tariff_plan_tier, plan: tariff_plan, weight: 10)
      ]
      client = instance_spy(CGRateS::Client)
      rating_engine_client = RatingEngineClient.new(client:)

      rating_engine_client.upsert_tariff_plan(tariff_plan)

      expect(client).to have_received(:set_tp_rating_plan).with(
        tp_id: tariff_plan.carrier_id,
        id: tariff_plan.id,
        rating_plan_bindings: [
          { weight: 20.0, timing_id: "*any", destination_rates_id: tiers[0].schedule_id },
          { weight: 10.0, timing_id: "*any", destination_rates_id: tiers[1].schedule_id }
        ]
      )
    end
  end

  describe "#destroy_tariff_plan" do
    it "sends a request to destroy a tariff plan" do
      tariff_plan = create(:tariff_plan)
      client = instance_spy(CGRateS::Client)
      rating_engine_client = RatingEngineClient.new(client:)

      rating_engine_client.destroy_tariff_plan(tariff_plan)

      expect(client).to have_received(:remove_tp_rating_plan).with(
        tp_id: tariff_plan.carrier_id,
        id: tariff_plan.id,
      )
    end
  end

  describe "#upsert_account" do
    it "sends a request to upsert an account" do
      account = create(:account)
      subscriptions = [
        create(:tariff_plan_subscription, :outbound_calls, account:),
        create(:tariff_plan_subscription, :outbound_messages, account:)
      ]
      client = instance_spy(CGRateS::Client)
      rating_engine_client = RatingEngineClient.new(client:)

      rating_engine_client.upsert_account(account)

      expect(client).to have_received(:set_account).with(
        tenant: "cgrates.org",
        account: account.id
      )
      subscriptions.each do |subscription|
        expect(client).to have_received(:set_tp_rating_profile).with(
          tp_id: account.carrier_id,
          load_id: "somleng.org",
          category: subscription.category,
          tenant: "cgrates.org",
          subject: account.id,
          rating_plan_activations: [
            {
              activation_time: subscription.created_at.iso8601,
              rating_plan_id: subscription.plan_id
            }
          ]
        )
      end
      [ "inbound_calls", "inbound_messages" ].each do |category|
        expect(client).to have_received(:remove_tp_rating_profile).with(
          tp_id: account.carrier_id,
          load_id: "somleng.org",
          category:,
          tenant: "cgrates.org",
          subject: account.id,
        )
      end
    end
  end

  describe "#destroy_account" do
    it "sends a request to destroy an account" do
      account = create(:account)
      client = instance_spy(CGRateS::Client)
      rating_engine_client = RatingEngineClient.new(client:)

      rating_engine_client.destroy_account(account)

      expect(client).to have_received(:remove_account).with(
        tenant: "cgrates.org",
        account: account.id
      )
    end
  end

  describe "#refresh_carrier_rates" do
    it "sends a request to refresh carrier rates" do
      carrier = create(:carrier)
      client = instance_spy(CGRateS::Client)
      rating_engine_client = RatingEngineClient.new(client:)

      rating_engine_client.refresh_carrier_rates(carrier)

      expect(client).to have_received(:load_tariff_plan_from_stor_db).with(
        tp_id: carrier.id
      )
    end
  end

  describe "#update_account_balance" do
    context "credit" do
      it "sends a request to add a balance" do
        balance_transaction = create(:balance_transaction, type: :topup, amount: Money.from_amount(100, "USD"))
        client = instance_spy(CGRateS::Client)
        rating_engine_client = RatingEngineClient.new(client:)

        rating_engine_client.update_account_balance(balance_transaction)

        expect(client).to have_received(:add_balance).with(
          tenant: "cgrates.org",
          account: balance_transaction.account_id,
          balance_type: "*monetary",
          value: 100.0,
          balance: {
            id: balance_transaction.account_id,
          },
          cdrlog: true
        )
      end
    end

    context "debit" do
      it "sends a request to debit a balance" do
        balance_transaction = create(:balance_transaction, type: :adjustment, amount: Money.from_amount(-100, "USD"))
        client = instance_spy(CGRateS::Client)
        rating_engine_client = RatingEngineClient.new(client:)

        rating_engine_client.update_account_balance(balance_transaction)

        expect(client).to have_received(:debit_balance).with(
          tenant: "cgrates.org",
          account: balance_transaction.account_id,
          balance_type: "*monetary",
          value: 100.0,
          balance: {
            id: balance_transaction.account_id,
          },
          cdrlog: true
        )
      end
    end
  end

  it "handles API errors" do
    client = instance_spy(CGRateS::Client)
    rating_engine_client = RatingEngineClient.new(client:)
    allow(client).to receive(:set_tp_destination).and_raise(CGRateS::Client::APIError.new("API error"))
    destination_group = create(:destination_group)

    expect {
      rating_engine_client.upsert_destination_group(destination_group)
    }.to raise_error(RatingEngineClient::APIError)
  end
end
