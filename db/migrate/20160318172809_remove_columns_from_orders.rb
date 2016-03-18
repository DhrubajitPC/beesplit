class RemoveColumnsFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :name, :string
    remove_column :orders, :price, :string
  end
end
