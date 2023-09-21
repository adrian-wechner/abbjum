# require 'pg'

# puts ENV["RAILS_ENV"]
# puts Rails.env.to_s
# puts Rails.env.inspect

# db_conf =  ActiveRecord::Base.configurations.configs_for env_name: Rails.env.to_s
# dbname = db_conf.first.database
# puts "DB_NAME => #{dbname}"

# conn = PG.connect(:dbname => dbname)


# plc_thread = Thread.new { system("ruby ./external/plc.rb") }
# ingersoll_threads = []
# sql = "select L.id as id, L.line_identifier as LID, S.id as sID, S.name as sName, S.ingersoll_ips as IPs from lines L JOIN stations S ON S.line_id = L.id;"

# res_line  = conn.exec(sql)
# # if the query affects 1 row, the query is clearly wrong. terminate client
# if res_line.cmd_tuples == 1
#   error_msg = "PLC SCRIPT: ERROR: SELECT query did affect 1 row. Rather (#{res_line.cmb_tuples}) => #{query_line}"
#   puts error_msg
#   client.puts "NOK:#{error_msg}" if client
#   client.close if client
# else
#   res_line.each do |s|
#     puts "res_line: #{s}"
#     s["ips"].to_s.split(",").each do |ip| 
#       ingersoll_threads.push Thread.new { system("ruby ./external/ingersoll_eor.rb -h #{ip} -l #{s['lid']} -s #{s['sname']}") }
#     end
#   end 
# end

