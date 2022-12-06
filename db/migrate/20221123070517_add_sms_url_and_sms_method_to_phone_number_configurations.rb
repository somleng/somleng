class AddSMSURLAndSMSMethodToPhoneNumberConfigurations < ActiveRecord::Migration[7.0]
  def change
    add_column :phone_number_configurations, :sms_url, :string
    add_column :phone_number_configurations, :sms_method, :string
  end
end
