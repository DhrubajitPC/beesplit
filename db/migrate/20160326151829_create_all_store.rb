class CreateAllStore < ActiveRecord::Migration
  def change
    create_table :all_stores do |t|
      t.integer :store_id
      t.string :address
    end
  end
end
