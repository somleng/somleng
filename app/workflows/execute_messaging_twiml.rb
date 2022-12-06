class ExecuteMessagingTwiML < ApplicationWorkflow
  class Error < StandardError; end

  SLEEP_BETWEEN_REDIRECTS = 1

  attr_reader :message, :url, :http_method, :twiml_parser, :error_message

  def initialize(options)
    @message = options.fetch(:message)
    @url = options.fetch(:url)
    @http_method = options.fetch(:http_method)
    @twiml_parser = options.fetch(:twiml_parser, TwiMLParser::Parser.new)
  end

  def call
    twiml.each do |verb|
      case verb.class.name
      when "Message"
        execute_message(verb)
      when "Redirect"
        return execute_redirect(verb)
      end
    end
  rescue Error, TwiMLParser::TwiMLError => e
    @error_message = e.message
  end

  private

  def execute_message(verb)
    schema = build_message_schema(verb)

    raise(Error, schema.errors(full: true).map(&:text).to_sentence) unless schema.success?

    SendOutboundMessage.call(
      Message.create!(
        schema.output.merge(direction: :outbound_reply)
      )
    )
  end

  def execute_redirect(verb)
    sleep(SLEEP_BETWEEN_REDIRECTS)

    ExecuteMessagingTwiML.call(
      message:,
      url: action_url(verb.url).to_s,
      http_method: verb.method || "POST"
    )
  end

  def twiml
    twiml_parser.parse(request_twiml)
  end

  def request_twiml
    TwilioAPI::NotifyWebhook.call(
      account: message.account,
      url:,
      http_method:,
      params: message_params
    ).body.to_s
  end

  def message_params
    @message_params ||= TwilioAPI::Webhook::MessageSerializer.new(
      MessageDecorator.new(message)
    ).as_json
  end

  def action_url(action)
    return if action.blank?

    URI.join(url, action).to_s
  end

  def build_message_schema(verb)
    TwilioAPI::MessageRequestSchema.new(
      input_params: {
        From: verb.from || message.to,
        To: verb.to || message.from,
        Body: verb.body,
        StatusCallback: action_url(verb.action),
        StatusCallbackMethod: verb.method
      },
      options: {
        account: message.account
      }
    )
  end
end
