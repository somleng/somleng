class OutboundCall
  attr_reader :call_params

  def initialize(call_params)
    @call_params = call_params
  end

  def initiate
    Adhearsion::OutboundCall.originate(
      dial_string,
      from: call_params.fetch("from"),
      controller: CallController,
      controller_metadata: {
        call_properties: CallProperties.new(
          voice_url: call_params.fetch("voice_url"),
          voice_method: call_params.fetch("voice_method"),
          account_sid: call_params.fetch("account_sid"),
          auth_token: call_params.fetch("account_auth_token"),
          call_sid: call_params.fetch("sid"),
          direction: call_params.fetch("direction"),
          api_version: call_params.fetch("api_version"),
          from: call_params.fetch("from"),
          to: call_params.fetch("to")
        )
      }
    )
  end

  private

  def routing_instructions
    call_params.fetch("routing_instructions", {})
  end

  def dial_string
    Utils.build_dial_string(routing_instructions.fetch("dial_string"))
  end
end
