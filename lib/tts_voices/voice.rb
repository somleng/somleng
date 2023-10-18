module TTSVoices
  class Voice
    class << self
      def all
        data_store.load(:all)
      end

      def basic
        data_store.load(:basic)
      end

      def polly
        data_store.load(:polly)
      end

      def find(identifier)
        all.find { |voice| voice.identifier == identifier }
      end

      private

      def data_store
        TTSVoices.data_store
      end
    end

    attr_reader :name, :gender, :language, :provider

    def initialize(name:, gender:, language:, provider:)
      @name = name
      @gender = gender
      @language = language
      @provider = provider
    end

    def identifier
      [provider.name, name].join(".")
    end
  end
end
