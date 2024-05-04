class AddCallServiceHostToPhoneCalls < ActiveRecord::Migration[7.1]
  def change
    add_column(:phone_calls, :call_service_host, :inet)
  end
end
