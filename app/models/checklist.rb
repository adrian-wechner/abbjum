class Checklist < ApplicationRecord
  belongs_to :line
  has_many :checklist_items
end
