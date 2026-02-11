class CreatePhoneCallsFromOutboundDial < ApplicationWorkflow
  attr_reader :parent_call, :from, :incoming_phone_number, :destinations, :session_limiters

  def initialize(params, **options)
    super()
    @parent_call = params.fetch(:parent_call)
    @from = params.fetch(:from)
    @incoming_phone_number = params.fetch(:incoming_phone_number)
    @destinations = params.fetch(:destinations)
    @session_limiters = options.fetch(:session_limiters) { [ AccountCallSessionLimiter.new, GlobalCallSessionLimiter.new ] }
  end

  def call
    destinations.map do |destination|
      phone_call = create_phone_call(
        to: destination.fetch(:destination),
        sip_trunk: destination.fetch(:sip_trunk)
      )
      session_limit(phone_call)
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

  def session_limit(phone_call)
    session_limiters.each { _1.add_session_to(phone_call.region.alias, scope: phone_call.account_id) }
  end
end
