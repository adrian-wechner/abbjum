class Checklist < ApplicationRecord
  belongs_to :line
  has_many :checklist_items
  has_many :checklist_records
end
