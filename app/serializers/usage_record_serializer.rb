class UsageRecordSerializer < ApplicationSerializer
  PRICE_UNIT = "usd".freeze

  attributes :category, :count, :price_unit, :subresource_uris,
             :description, :end_date, :usage_unit, :price,
             :uri, :account_sid, :usage, :start_date, :count_unit

  def price_unit
    PRICE_UNIT
  end

  def subresource_uris; end

  def uri
    url_helpers.api_twilio_account_usage_records_path(serializable.account, uri_query_params)
  end

  def account_sid
    serializable.account.id
  end

  def count
    serializable.count.to_s
  end

  def price
    serializable.price.to_s
  end

  def usage
    serializable.usage.to_s
  end

  private

  def uri_query_params
    {
      Category: category,
      StartDate: start_date,
      EndDate: end_date
    }.compact
  end
end
