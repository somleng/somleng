class Api::Admin::AwsSnsMessagesController < Api::Admin::BaseController
  PERMITTED_HEADERS = %w[
    HTTP_X_AMZ_SNS_MESSAGE_TYPE
    HTTP_X_AMZ_SNS_MESSAGE_ID
    HTTP_X_AMZ_SNS_TOPIC_ARN
    HTTP_X_AMZ_SNS_SUBSCRIPTION_ARN
  ].freeze

  def create
    AwsSnsMessageProcessorJob.perform_later(permitted_headers, request.raw_post)
    head(:created)
  end

  private

  def permitted_headers
    request.headers.to_h.slice(*PERMITTED_HEADERS)
  end
end
