class RatingEngineClient
  class APIError < StandardError; end

  def create_destination_group(destination_group)
    client.set_tp_destination(
      tp_id: destination_group.carrier.id,
      id: destination_group.id,
      prefixes: destination_group.prefixes.pluck(:prefix),
    )
  end

  private

  def make_request
    yield
  rescue CGRateS::APIError => e
    raise APIError.new(e.message)
  end

  def client
    @client ||= CGRateS::Client.new
  end
end
