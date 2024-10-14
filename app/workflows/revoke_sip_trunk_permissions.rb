class RevokeSIPTrunkPermissions < ApplicationWorkflow
  def call
    InboundSourceIPAddress.unused.destroy_all
  end
end
