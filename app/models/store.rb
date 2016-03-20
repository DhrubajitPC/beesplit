class Store < ActiveRecord::Base
  has_many :items
  belongs_to :all_store
end
