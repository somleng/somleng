class APIRequestErrorsSerializer < ApplicationSerializer
  def attributes
    {
      message: nil,
      status: nil,
      code: nil,
      more_info: nil
    }
  end

  def message
    errors(full: true).to_h.values.flatten.to_sentence
  end

  def status
    422
  end

  def code
    20422
  end

  def more_info
    if options[:log].present?
      url_helpers.dashboard_log_url(options.fetch(:log))
    else
      "https://www.twilio.com/docs/errors/20422"
    end
  end
end
