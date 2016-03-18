class AddStatusToBees < ActiveRecord::Migration
  def change
    add_column :bees, :status, :integer
  end
end
