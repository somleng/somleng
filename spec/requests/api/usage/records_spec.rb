require "rails_helper"

describe "Usage Records API" do
  describe "GET /api/2010-04-01/Accounts/{AccountSid}/Usage/Records" do
    it "fetches the usage records" do
      account = create(:account)
      params = {}

      get(
        api_twilio_account_usage_records_path(account.id, params),
        headers: build_api_authorization_headers(account)
      )

      expect(response.code).to eq("200")
      expect(response.body).to match_api_response_schema(:usage_record_collection)
    end

    it "handles invalid requests" do
      account = create(:account)
      params = { Category: "foo" }

      get(
        api_twilio_account_usage_records_path(account, params),
        headers: build_api_authorization_headers(account)
      )

      expect(response.code).to eq("422")
      expect(response.body).to match_api_response_schema(:api_error)
    end

    it "filters by start and end date" do
      account = create(:account)
      create_cdr(account: account, start_time: Date.parse("2018-01-01"))

      #TODO: move this logic out into unit test
      create_cdr(
        account: account,
        bill_sec: 1,
        price: Money.new(50_000, "USD6"),
        start_time: Date.parse("2018-01-02")
      )
      create_cdr(
        account: account,
        bill_sec: 61,
        price: Money.new(50_000, "USD6"),
        start_time: Date.parse("2018-01-03")
      )
      create_cdr(account: account, start_time: Date.parse("2018-01-04"))

      params = {
        StartDate: "2018-01-02",
        EndDate: "2018-01-03",
        Category: "calls"
      }

      get(
        api_twilio_account_usage_records_path(account, params),
        headers: build_api_authorization_headers(account)
      )

      expect(response.code).to eq("200")
      expect(response.body).to match_api_response_schema(:usage_record_collection)
      usage_record = JSON.parse(response.body).fetch("usage_records").first
      expect(usage_record.fetch("start_date")).to eq("2018-01-02")
      expect(usage_record.fetch("end_date")).to eq("2018-01-03")
      expect(usage_record.fetch("category")).to eq("calls")
      expect(usage_record.fetch("count")).to eq("2")
      expect(usage_record.fetch("usage")).to eq("3")
      expect(usage_record.fetch("price")).to eq("0.10")
    end
  end

  def create_cdr(account:, **options)
    phone_call = create(:phone_call, account: account)
    create(:call_data_record, :billable, phone_call: phone_call, **options)
  end
end
