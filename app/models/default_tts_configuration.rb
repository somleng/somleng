class DefaultTTSConfiguration < ApplicationRecord
  extend Enumerize

  belongs_to :account

  enumerize :provider, in: %i[basic polly], default: :basic
  enumerize :language, in: ["en-us"], default: "en-us"
  enumerize :voice, in: %w[kal], default: "kal"
end
