class CreateBees < ActiveRecord::Migration
  def change
    create_table :bees do |t|

      t.string :name, null: false
      t.string :contact_no, null: false
      t.string :email, null: false
      t.integer :ratings, default: 0

      t.timestamps null: false
    end
  end
end
