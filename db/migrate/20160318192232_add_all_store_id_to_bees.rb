class AddAllStoreIdToBees < ActiveRecord::Migration
  def change
    add_column :bees, :all_store_id, :integer
  end
end
