class Bee < ActiveRecord::Base
  has_many :all_orders
  belongs_to :all_store
end
