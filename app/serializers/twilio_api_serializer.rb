class TwilioAPISerializer < ApplicationSerializer
  API_VERSION = "2010-04-01".freeze

  def serializable_hash(options = nil)
    serializable_is_collection? ? hash_for_collection(options) : super
  end
  alias to_hash serializable_hash

  def api_version
    API_VERSION
  end

  def sid
    object.id
  end

  def account_sid
    object.account_id
  end

  private

  def hash_for_collection(options)
    data = object.map do |record|
      self.class.new(record.decorated).serializable_hash(options)
    end

    {
      collection_name => data,
      :uri => serializer_options.fetch(:url),
      :page => object.current_page,
      :page_size => object.limit_value,
      :first_page_uri => build_page_uri(1),
      :next_page_uri => build_page_uri(object.next_page),
      :previous_page_uri => build_page_uri(object.prev_page)
    }
  end

  def build_page_uri(page_number)
    return if page_number.blank?

    uri = URI(serializer_options.fetch(:url))
    params = Hash[URI.decode_www_form(uri.query || "")]
    params["PageSize"] = object.limit_value
    if page_number == 1
      params.delete("Page")
    else
      params["Page"] = page_number
    end

    uri.query = URI.encode_www_form(params)
    uri.to_s
  end

  def serializable_is_collection?
    object.respond_to?(:each) && object.respond_to?(:size)
  end

  def collection_name
    self.class.name.demodulize.gsub("Serializer", "").underscore.pluralize.to_sym
  end


  def format_time(value)
    return if value.blank?

    value.utc.rfc2822
  end
end
