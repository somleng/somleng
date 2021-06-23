class InboundSIPTrunk < ApplicationRecord
  include SourceIPCallbacks

  belongs_to :carrier
end
