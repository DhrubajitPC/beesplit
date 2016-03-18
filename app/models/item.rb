class Item < ActiveRecord::Base
  belongs_to :orders
  has_and_belongs_to_many :stores
end
