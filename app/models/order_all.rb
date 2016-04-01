class OrderAll < ActiveRecord::Base
	belongs_to :parent, :class_name => "OrderAll"
  has_many :orders
	belongs_to:bee

  accepts_nested_attributes_for :orders
end