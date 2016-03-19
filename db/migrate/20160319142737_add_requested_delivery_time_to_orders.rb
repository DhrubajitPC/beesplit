class AddRequestedDeliveryTimeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_time, :date
  end
end
