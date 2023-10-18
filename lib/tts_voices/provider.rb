module TTSVoices
  class Provider
    TYPES = %w[Basic Polly].freeze

    class << self
      def find(name)
        all.find { |provider| provider.name == name.to_s }
      end

      def all
        @all ||= TYPES.each do |type|
          new(name: type)
        end
      end
    end

    attr_reader :name

    def initialize(name:)
      @name = name
    end
  end
end
