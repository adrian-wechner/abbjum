require 'pg'

# puts ENV["RAILS_ENV"]
# puts Rails.env.to_s
# puts Rails.env.inspect

db_conf =  ActiveRecord::Base.configurations.configs_for env_name: Rails.env.to_s
db_name = db_conf.first.database

puts db_conf.first.database

plc_thread = Thread.new { system("ruby ./external/plc.rb") }


# system("ruby ./external/ingersoll_eor.rb")

