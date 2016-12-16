class AddSipInviteFailureStatusAndSipInviteFailurePhraseToCallDataRecords < ActiveRecord::Migration[5.0]
  def change
    add_column(:call_data_records, :sip_invite_failure_status, :string)
    add_column(:call_data_records, :sip_invite_failure_phrase, :string)
  end
end
