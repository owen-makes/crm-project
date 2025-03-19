class UpdateSecuritySecurityType < ActiveRecord::Migration[7.2]
  def up
    # Create a new integer column with a temporary name
    add_column :securities, :security_type_integer, :integer

    # Map string values to integers based on your enum
    execute <<-SQL
      UPDATE securities#{' '}
      SET security_type_integer = CASE security_type
        WHEN 'stock' THEN 0
        WHEN 'bond' THEN 1
        WHEN 'etf' THEN 2
        WHEN 'mutual_fund' THEN 3
        WHEN 'option' THEN 4
        WHEN 'future' THEN 5
        WHEN 'cedear' THEN 6
        WHEN 'real_estate_trust' THEN 7
        WHEN 'commodity' THEN 8
        ELSE NULL
      END
    SQL

    # Remove the old column
    remove_column :securities, :security_type

    # Add a new column with the original name
    add_column :securities, :security_type, :integer

    # Copy data from temporary column
    execute "UPDATE securities SET security_type = security_type_integer"

    # Remove the temporary column
    remove_column :securities, :security_type_integer
  end

  def down
    # Create a temporary string column
    add_column :securities, :security_type_string, :string

    # Map integers back to strings
    execute <<-SQL
      UPDATE securities#{' '}
      SET security_type_string = CASE security_type
        WHEN 0 THEN 'stock'
        WHEN 1 THEN 'bond'
        WHEN 2 THEN 'etf'
        WHEN 3 THEN 'mutual_fund'
        WHEN 4 THEN 'option'
        WHEN 5 THEN 'future'
        WHEN 6 THEN 'cedear'
        WHEN 7 THEN 'real_estate_trust'
        WHEN 8 THEN 'commodity'
        ELSE NULL
      END
    SQL

    # Remove the integer column
    remove_column :securities, :security_type

    # Add back a string column with the original name
    add_column :securities, :security_type, :string

    # Copy data from temporary column
    execute "UPDATE securities SET security_type = security_type_string"

    # Remove the temporary column
    remove_column :securities, :security_type_string
  end
end
