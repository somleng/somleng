class SMSMessageChannel < ApplicationCable::Channel
  def subscribed
    stream_for(current_sms_gateway)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def sent(data)
    puts "Delivery Receipt: " + data.to_s
  end

  def received(data)
    puts "Received: " + data.to_s
  end
end
