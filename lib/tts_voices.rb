module TTSVoices
  class << self
    def data_store
      @data_store ||= reset_data_store!
    end

    private

    def reset_data_store!
      @data_store = StoreCache.new(DataStore.new)
    end
  end
end
