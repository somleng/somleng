module TTSVoices
  module DataSource
    class AllVoices
      def load_data
        voices = [BasicVoices, PollyVoices].each_with_object([]) do |data_source, result|
          result << data_source.new.load_data
        end
        voices.flatten
      end
    end
  end
end
