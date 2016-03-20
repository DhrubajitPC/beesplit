class Bee < ActiveRecord::Base
  has_many :orders
  belongs_to :all_store

  enum status: [:busy, :free, :unavailable]
end
