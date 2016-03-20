class RenameColumnInOrders < ActiveRecord::Migration
  def change
    rename_column :orders, :bees_id, :bee_id
  end
end
