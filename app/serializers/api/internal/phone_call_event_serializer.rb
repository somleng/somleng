module API
  module Internal
    class PhoneCallEventSerializer < ApplicationSerializer
      attributes :recording_url

      def recording_url
        serializable.recording_url
      end
    end
  end
end
