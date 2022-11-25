class ExecuteMessagingTwiML < ApplicationWorkflow
  SLEEP_BETWEEN_REDIRECTS = 1

  class TwiMLError < StandardError; end

  attr_reader :message, :url, :http_method

  def initialize(message:, url:, http_method:)
    @message = message
    @url = url
    @http_method = http_method
  end

  def call
    redirect_args = catch(:redirect) do
      twiml_doc.each do |verb|
        next if verb.comment?

        case verb.name
        when "Message"
          execute_message(verb)
        when "Redirect"
          execute_redirect(verb)
        else
          raise TwiMLError, "Invalid element '#{verb.name}'"
        end
      end

      false
    end

    redirect(*redirect_args) if redirect_args.present?
  rescue TwiMLError
  end

  private

  def execute_message(verb)
    attributes = twiml_attributes(verb)
    nested_noun = verb.children.first
    body = nested_noun.content if nested_noun.text? || nested_noun.name == "Body"
    action = URI.join(url, attributes["action"]).to_s if attributes.key?("action")

    schema = TwilioAPI::MessageRequestSchema.new(
      input_params: {
        From: attributes.fetch("from", message.to),
        To: attributes.fetch("to", message.from),
        Body: body,
        StatusCallback: action,
        StatusCallbackMethod: attributes["method"]
      },
      options: {
        account: message.account
      }
    )

    if schema.success?
      reply_message = CreateMessage.call(schema.output.merge(direction: :outbound_reply))
      InitiateOutboundMessage.call(reply_message)
    else
      raise TwiMLError, "Invalid <Message> verb's attributes"
    end
  end

  def execute_redirect(verb)
    raise TwiMLError, "Redirect must contain a URL" if verb.content.blank?

    sleep(SLEEP_BETWEEN_REDIRECTS)

    attributes = twiml_attributes(verb)
    throw(
      :redirect,
      [
        verb.content,
        attributes.fetch("method", "POST")
      ]
    )
  end

  def twiml_attributes(node)
    node.attributes.transform_values(&:value)
  end

  def redirect(redirect_url, http_method)
    ExecuteMessagingTwiML.call(
      message:,
      url: URI.join(url, redirect_url).to_s,
      http_method:
    )
  end

  def twiml_doc
    twiml = request_twiml

    doc = ::Nokogiri::XML(twiml.strip) do |config|
      config.options = Nokogiri::XML::ParseOptions::NOBLANKS
    end

    if doc.root.name != "Response"
      raise(TwiMLError,
            "The root element must be the '<Response>' element")
    end

    doc.root.children
  rescue Nokogiri::XML::SyntaxError => e
    raise TwiMLError, "Error while parsing XML: #{e.message}. XML Document: #{twiml}"
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
end
