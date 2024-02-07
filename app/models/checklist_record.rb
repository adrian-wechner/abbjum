class ChecklistRecord < ApplicationRecord
  belongs_to :checklist
  belongs_to :line
  belongs_to :product
  belongs_to :user_start, class_name: "User", foreign_key: "user_start_id", optional: true
  belongs_to :user_complete, class_name: "User", foreign_key: "user_complete_id", optional: true

  validates :product_id, presence: true
  validates :quantity, comparison: { greater_than: 0 }
  validates :shift, comparison: { greater_than: 0 }
end
