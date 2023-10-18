require "delegate"

module TTSVoices
  class StoreCache < SimpleDelegator
    attr_reader :cached

    def initialize(data_store)
      super(data_store)

      @cached = {}
    end

    def load(type, *args)
      cached.fetch(type) do
        cached[type] = super
      end
    end
  end
end
