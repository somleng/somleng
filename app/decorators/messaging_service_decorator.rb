class MessagingServiceDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: "MessagingService"
  end

  def sender_pool_size
    object.incoming_phone_numbers.size + object.alphanumeric_sender_ids.size
  end

  private

  def object
    __getobj__
  end
end
