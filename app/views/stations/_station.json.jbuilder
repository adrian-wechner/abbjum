json.extract! station, :id, :name, :line_id, :model, :operator_instructions, :ingersoll_ips, :hipot_ips, :created_at, :updated_at
json.url station_url(station, format: :json)
