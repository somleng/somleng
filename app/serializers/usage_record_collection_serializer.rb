class UsageRecordCollectionSerializer < ApplicationSerializer
  PAGE_SIZE = 50

  attributes :first_page_uri, :previous_page_uri, :next_page_uri, :page,
             :uri, :page_size, :usage_records

  def first_page_uri
    uri
  end

  def previous_page_uri; end

  def next_page_uri; end

  def page
    0
  end

  def page_size
    PAGE_SIZE
  end

  def uri
    url_helpers.api_twilio_account_usage_records_path(account, filter_params)
  end

  def usage_records
    serialize_collection(
      serializable.usage_records,
      item_serializer_class: UsageRecordSerializer
    )
  end
end
