class CreatePhoneCallsFromOutboundDial < ApplicationWorkflow
  attr_reader :parent_call, :from, :incoming_phone_number, :destinations

  def initialize(options)
    @parent_call = options.fetch(:parent_call)
    @from = options.fetch(:from)
    @incoming_phone_number = options.fetch(:incoming_phone_number)
    @destinations = options.fetch(:destinations)
  end

  def call
    destinations.map do |destination|
       create_phone_call(
        to: destination.fetch(:destination),
        sip_trunk: destination.fetch(:sip_trunk)
      )
    end
  end

  private

  def create_phone_call(to:, sip_trunk:)
    PhoneCall.create!(
      account: parent_call.account,
      carrier: parent_call.carrier,
      parent_call:,
      sip_trunk:,
      incoming_phone_number:,
      to:,
      from:,
      phone_number: incoming_phone_number&.phone_number,
      direction: :outbound_dial
    )
  end
end
