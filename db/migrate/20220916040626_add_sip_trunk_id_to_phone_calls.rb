class AddSIPTrunkIDToPhoneCalls < ActiveRecord::Migration[7.0]
  class OutboundSIPTrunk < ActiveRecord::Base
  end

  class InboundSIPTrunk < ActiveRecord::Base
  end

  def change
    add_reference(:phone_calls, :sip_trunk, type: :uuid, foreign_key: true)
  end
end
