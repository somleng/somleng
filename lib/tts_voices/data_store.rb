module TTSVoices
  class DataStore
    def load(type)
      case type
      when :all
        DataSource::AllVoices.new.load_data
      when :basic
        DataSource::BasicVoices.new.load_data
      when :polly
        DataSource::PollyVoices.new.load_data
      end
    end
  end
end
