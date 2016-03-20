class Order < ActiveRecord::Base
  belongs_to :bee
  has_many :items
end
