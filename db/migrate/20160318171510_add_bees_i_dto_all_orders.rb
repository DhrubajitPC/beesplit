class AddBeesIDtoAllOrders < ActiveRecord::Migration
  def change
    add_column :all_orders, :bee_id, :integer
  end
end
