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

  # destination_rules = DestinationRules.new(account:, destination:)

  # if destination_rules.valid?
  #   sip_trunk = destination_rules.sip_trunk
  #   routing_parameters = RoutingParameters.new(sip_trunk:, destination:).to_h

  #   render(
  #     json: routing_parameters,
  #     status: :created
  #   )
  # else
  #   head :not_implemented
  # end


  # {
  #   account:,
  #   carrier: account.carrier,
  #   sip_trunk: context.fetch(:sip_trunk),
  #   to: params.fetch(:To),
  #   from: params.fetch(:From),
  #   incoming_phone_number: context[:incoming_phone_number],
  #   phone_number: context[:incoming_phone_number]&.phone_number || sender,
  #   caller_id:,
  #   voice_url: params[:Url],
  #   voice_method: params.fetch(:Method) { "POST" if params.key?(:Url) },
  #   status_callback_url: params[:StatusCallback],
  #   status_callback_method: params[:StatusCallbackMethod],
  #   twiml: (params[:Twiml] unless params.key?(:Url)),
  #   direction: :outbound
  # }
end
