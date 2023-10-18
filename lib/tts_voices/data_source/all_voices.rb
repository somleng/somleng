module TTSVoices
  module DataSource
    class AllVoices
      def self.load_data
        [BasicVoices, PollyVoices].map(&:load_data).flatten
      end
    end
  end
end
