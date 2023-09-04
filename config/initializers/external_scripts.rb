require 'pg'

# puts ENV["RAILS_ENV"]
# puts Rails.env.to_s
# puts Rails.env.inspect

db_conf =  ActiveRecord::Base.configurations.configs_for env_name: Rails.env.to_s
db_name = db_conf.first.database
puts db_name

conn = PG.connect(:dbname => db_name)


plc_thread = Thread.new { system("ruby ./external/plc.rb") }
ingersoll_threads = []
sql = "select L.id as id, L.line_identifier as LID, S.id as sID, S.name as sName, S.ingersoll_ips as IPs from lines L JOIN stations S ON S.line_id = L.id;"
 sql = "SELECT * from lines where line_identifier = '#{line_id}';" 
  res_line  = conn.exec(query_line)
  # if the query affects 1 row, the query is clearly wrong. terminate client
  if res_line.cmd_tuples != 1
    error_msg = "PLC SCRIPT: ERROR: SELECT query did affect 1 row. Rather (#{res_line.cmb_tuples}) => #{query_line}"
    puts error_msg
    client.puts "NOK:#{error_msg}" if client
    client.close if client
    return false

ingersoll_threads.push Thread.new { system("ruby ./external/ingersoll_eor.rb") }

# system("ruby ./external/ingersoll_eor.rb")

