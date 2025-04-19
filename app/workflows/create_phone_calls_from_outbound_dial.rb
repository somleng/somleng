class CreatePhoneCallsFromOutboundDial < ApplicationWorkflow
  attr_reader :parent_call, :from, :incoming_phone_number, :destinations, :session_limiter

  def initialize(**options)
    super()
    @parent_call = options.fetch(:parent_call)
    @from = options.fetch(:from)
    @incoming_phone_number = options.fetch(:incoming_phone_number)
    @destinations = options.fetch(:destinations)
    @session_limiter = options.fetch(:session_limiter) { PhoneCallSessionLimiter.new }
  end

  def call
    destinations.map do |destination|
      phone_call = create_phone_call(
        to: destination.fetch(:destination),
        sip_trunk: destination.fetch(:sip_trunk)
      )
      session_limiter.add_session_to(phone_call.region.alias)
      phone_call
    end
  end

  private

  def create_phone_call(to:, sip_trunk:)
    PhoneCall.create!(
      account: parent_call.account,
      carrier: parent_call.carrier,
      region: parent_call.region,
      parent_call:,
      sip_trunk:,
      incoming_phone_number:,
      to:,
      from:,
      phone_number: incoming_phone_number&.phone_number,
      direction: :outbound_dial,
      status: :initiated
    )
  end
end
