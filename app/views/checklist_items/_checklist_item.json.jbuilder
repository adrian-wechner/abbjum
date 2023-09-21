json.extract! checklist_item, :id, :checklist_id, :ident, :label, :primaryanswers, :primaryanswertype, :itemtype, :ordernum, :secondaryanswertype, :created_at, :updated_at
json.url checklist_item_url(checklist_item, format: :json)
