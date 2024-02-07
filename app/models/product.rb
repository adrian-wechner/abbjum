class Product < ApplicationRecord
  belongs_to :line
  enum status: { inactive: 0, active: 1 }
end
