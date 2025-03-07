class AddSecurityTypeToSecurities < ActiveRecord::Migration[7.2]
  def change
    add_column :securities, :security_type, :string
  end
end
