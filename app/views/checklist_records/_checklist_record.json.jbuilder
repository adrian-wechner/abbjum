json.extract! checklist_record, :id, :checklist_id, :user_start_id, :user_complete_id, :line_id, :catalogue, :checkstart, :checkend, :quantity, :shift, :comments, :deviationrun, :deviationcomment, :created_at, :updated_at
json.url checklist_record_url(checklist_record, format: :json)
