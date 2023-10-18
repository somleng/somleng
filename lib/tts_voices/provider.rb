module TTSVoices
  class Provider
    Type = Struct.new(:name, :required_credentials, keyword_init: true)
    TYPES = [
      Type.new(name: "Basic"),
      Type.new(name: "Polly", required_credentials: %w[access_key_id secret_access_key])
    ].freeze

    class << self
      def find(name)
        all.find { |provider| provider.name == name.to_s }
      end

      def all
        @all ||= TYPES.each do |type|
          new(name: type.name, required_credentials: type.required_credentials)
        end
      end
    end

    attr_reader :name, :required_credentials

    def initialize(name:, required_credentials:)
      @name = name
      @required_credentials = required_credentials
    end

    def friendly_name
      name.capitalize
    end
  end
end
