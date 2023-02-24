class AddCustomThemeCssToCarriers < ActiveRecord::Migration[7.0]
  def change
    add_column :carriers, :custom_theme_css, :text
  end
end
