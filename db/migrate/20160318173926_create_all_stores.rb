class CreateAllStores < ActiveRecord::Migration
  def change
    create_table :all_stores do |t|
      t.string :address

      t.timestamps null: false
    end
  end
end
