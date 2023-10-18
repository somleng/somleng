module TTSVoices
  class DataStore
    def load(type)
      case type
      when :all
        DataSource::AllVoices.load_data
      when :basic
        DataSource::BasicVoices.load_data
      when :polly
        DataSource::PollyVoices.load_data
      end
    end
  end
end
