class Order < ActiveRecord::Base
  belongs_to :all_order
  has_many :items
end
