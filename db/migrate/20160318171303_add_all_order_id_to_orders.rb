class AddAllOrderIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :all_order_id, :integer
  end
end
