class AddAllOrderIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :all_order_id, :datetime
  end
end
