json.extract! line, :id, :name, :localpath, :remotepath, :trackingpath, :created_at, :updated_at
json.url line_url(line, format: :json)
