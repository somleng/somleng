module TTSVoices
  module DataSource
    class BasicVoices
      attr_reader :data_directory

      DEFAULT_DATA_DIRECTORY = File.join(File.expand_path(File.dirname(__dir__)), "data")

      def initialize(data_directory: DEFAULT_DATA_DIRECTORY)
        @data_directory = Pathname(data_directory)
      end

      def load_data
        provider = Provider.find("Basic")
        voices.each_with_object([]) do |(voice, attributes), result|
          result << Voice.new(
            provider:,
            name: voice.titleize,
            language: attributes.fetch("language"),
            gender: attributes.fetch("gender").titleize
          )
        end
      end

      private

      def raw_data
        @raw_data ||= YAML.load_file(data_directory.join("basic_voices.yml"))
      end

      def voices
        raw_data.dig("voices", "basic")
      end
    end
  end
end
