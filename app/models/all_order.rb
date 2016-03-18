class AllOrder < ActiveRecord::Base
  has_many :orders
  belongs_to :bee
end
