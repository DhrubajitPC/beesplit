class ChangeOrderAndItemsTable < ActiveRecord::Migration
  def change
    remove_column :orders, :item_id
    add_column :items, :order_id, :integer
  end
end
