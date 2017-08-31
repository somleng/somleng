module EventPublisher
  extend ActiveSupport::Concern

  include Wisper::Publisher

  included do
    after_commit   :publish_created, :on => :create
    delegate       :to_event_name,   :to => :class
  end

  module ClassMethods
    def to_event_name
      to_s.underscore
    end
  end

  private

  def publish_created
    broadcast(broadcast_event_name(:created), self)
  end

  def broadcast_event_name(event_type)
    [to_event_name, event_type].join("_")
  end
end
