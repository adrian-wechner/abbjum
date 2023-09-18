class ChecklistRecord < ApplicationRecord
  belongs_to :checklist
  belongs_to :line
  belongs_to :user_start, class_name: "User", foreign_key: "user_start_id"
  belongs_to :user_complete, class_name: "User", foreign_key: "user_complete_id"
end
