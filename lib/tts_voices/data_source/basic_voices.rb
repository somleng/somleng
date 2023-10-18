module TTSVoices
  module DataSource
    class BasicVoices
      DATA = {
        "Kal" => { "language" => "en-us", "gender" => "Male" },
        "Slt" => { "language" => "en-us", "gender" => "Female" }
      }.freeze

      def self.load_data
        new.load_data
      end

      def load_data
        provider = Provider.find("Basic")
        DATA.each_with_object([]) do |(voice, attributes), result|
          result << Voice.new(
            provider:,
            name: voice,
            language: attributes.fetch("language"),
            gender: attributes.fetch("gender")
          )
        end
      end
    end
  end
end
