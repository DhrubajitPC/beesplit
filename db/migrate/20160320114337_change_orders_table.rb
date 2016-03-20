class ChangeOrdersTable < ActiveRecord::Migration
  def change
    rename_column :orders, :all_order_id, :bees_id
  end
end
