class AddCallPlatformHostToPhoneCalls < ActiveRecord::Migration[7.1]
  def change
    add_column(:phone_calls, :call_platform_host, :inet)
  end
end
