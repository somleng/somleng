class RefreshCarrierRates < ApplicationWorkflow
  attr_reader :client

  def initialize(**options)
    super()
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call
    Carrier.find_each do |carrier|
      client.refresh_carrier_rates(carrier)
    end
  end
end
