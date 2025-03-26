class RenameHoldingCostBasisToPurchasePrice < ActiveRecord::Migration[7.2]
  def change
    rename_column :holdings, :cost_basis, :purchase_price
  end
end
