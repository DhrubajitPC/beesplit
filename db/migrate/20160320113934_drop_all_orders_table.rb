class DropAllOrdersTable < ActiveRecord::Migration
  def change
    drop_table :all_orders
  end
end
