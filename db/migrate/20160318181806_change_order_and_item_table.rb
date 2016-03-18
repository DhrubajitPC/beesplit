class ChangeOrderAndItemTable < ActiveRecord::Migration
  def change
    remove_column :items, :order_id, :integer
    add_column :orders, :item_id, :integer
  end
end
