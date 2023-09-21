class User < ApplicationRecord
  
  has_many :checklist_starts, class_name: "ChecklistRecord", foreign_key: "user_start_id"
  has_many :checklist_completes, class_name: "ChecklistRecord", foreign_key: "user_complete_id"

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
