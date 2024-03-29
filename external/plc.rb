require 'socket'
require 'pg'
require 'json'
require 'fileutils'
require 'csv'

def safe_puts(client, msg)
  begin
    client.puts msg
  rescue Exception
    client.close if client
  end
end

def hipot_row_datetime_into_civil(row)
  DateTime.parse("#{row['Date']} #{row['Time']}").strftime("%F %H-%M-%S")
end

def hipot_row_into_file_suffix(row, line_ident, station)
  "#{hipot_row_datetime_into_civil(row)} #{line_ident} #{station} #{row['Serial No']} HIPOT #{row['Catalog']}"
end

def hipot_row_into_file_name(row, line_ident, station)
  "#{hipot_row_into_file_suffix(row, line_ident, station)}-#{row['Serial No']}-#{row['Plant Code']}.csv"
end

def relative_folder_to_part_instance(line_ident, station_name, part_instance)
  abb_timestamp = part_instance.split("_").last

  # YEAR
  year_digit = abb_timestamp[3]
  year = "202#{year_digit}"
  year = "203#{year_digit}" if Time.now.year >= 2030

  # WEEK
  week_digits = abb_timestamp[4..5]

  # WEEK-DAY
  week_day_digit = abb_timestamp[7]

  #### FULL SUB-STRUCTURE FOLDER PATH TO PART AND STATION
  "/#{line_ident}/#{year}/#{week_digits}/#{week_day_digit}/#{part_instance}/#{station_name}/"
end

def trck_file_name(line_ident, station_name, part_instance, file_appendix)
  "#{Time.now.strftime("%Y-%m-%d %H-%M-%S")} #{line_ident} #{station_name} #{part_instance} #{file_appendix.gsub("/", "-")}"
end

def trck_file_path(line_ident, station_name, part_instance, file_appendix, root_path="")
  File.join(root_path, relative_folder_to_part_instance(line_ident, station_name, part_instance), trck_file_name(line_ident, station_name, part_instance, file_appendix))
end

# CHECK LINE
# RETURNS DB SERACH RESULT LINE-RECORD
def check_line(conn, client, line_ident)
  query_line = "SELECT * from lines where line_identifier = '#{line_ident}';" 
  res_line  = conn.exec(query_line)
  # if the query affects 1 row, the query is clearly wrong. terminate client
  if res_line.cmd_tuples != 1
    error_msg = "PLC SCRIPT: ERROR: SELECT query did affect 1 row. Rather (#{res_line.cmd_tuples}) => #{query_line}"
    puts error_msg
    client.puts "NOK:#{error_msg}" if client
    client.close if client
    return nil # false
  end
  return res_line
end

# CHECK STATION
def check_station(conn, client, line_ident, station_name)
  query_station = "SELECT * from stations where line_id IN (SELECT id from lines where line_identifier = '#{line_ident}') AND name = '#{station_name}'"
  res_station = conn.exec(query_station)
  # if the query affects 1 row, the query is clearly wrong. terminate client
  if res_station.cmd_tuples != 1
    error_msg = "ERROR: SELECT query did affect 1 row. Rather (#{res_station.cmd_tuples}) => #{query_station}"
    puts error_msg
    client.puts "NOK:#{error_msg}" if client
    client.close if client
    return nil # false 
  end
  return res_station
end

# CHECK PRODUCT
def check_product(conn, client, model_name)
  query_product = "SELECT * from products where catalog = '#{model_name}'"
  res_product = conn.exec(query_product)
  # if the query affects 1 row, the query is clearly wrong. terminate client
  if res_product.cmd_tuples != 1
    error_msg = "ERROR: SELECT query did affect 1 row. Rather (#{res_product.cmd_tuples}) => #{query_product}"
    puts error_msg
    client.puts "NOK:#{error_msg}" if client
    client.close if client
    return nil # false 
  end
  return res_product
end

def hipot_command(client, data)

  # HIPOT data can include : charater.
  # will rejoin, and ONLY split into 3 parts. This will preserver 
  # the full HIPOT content string
  data = data.join(":").split(":",4)
  csv = nil

  if data.length != 4
    puts "PLC SCRIPT: ERROR: WRONG LENGTH(4) for HIPOT command"
    client.close
    return false
  end

  conn = PG.connect(:dbname => PG_DBNAME)

  line_ident = data[1] # "example: MET"
  station_name = data[2] # "example: ST80"
  content = data[3].gsub("__NL__", "\n")

  begin
    csv = CSV.parse(content, headers: true).by_row
  rescue #Exception => e
    puts "ERROR: "##{e}"
    return
  end

  res_line = check_line(conn, client, line_ident)
  return false if res_line.nil?
  
  i = csv.length - 1
  while i >= 0 
    row = csv[i]

    part_instance = "#{row['Catalog']}_#{row['Serial No']}_#{row['Plant Code']}"
    folder = File.join(res_line[0]['trackingpath'], relative_folder_to_part_instance(line_ident, station_name, part_instance))
    files = Dir["#{folder}/*.csv"]
    
    # generate file name
    found = false
    files.each do |file|
      # if a file with the same suffix in the same folder already exists
      # then this data has been stored already. And any further advancements
      # in the csv file can be stopped. As we already found the most recent
      # stored value.
      reg = Regexp.new(hipot_row_into_file_suffix(row, line_ident, station_name))
      unless reg.match(file).nil?
        puts "HIPOT CSV: FOUND #{file}"
        found = true
        break # leave while loop
      end
    end

    break if found

    # !! only store new data if not have been found already
    # store using standrd function sand same "suffix"-method
    unless found
      filename = File.join(res_line[0]['trackingpath'], relative_folder_to_part_instance(line_ident, station_name, part_instance), hipot_row_into_file_name(row, line_ident, station_name))
      puts "HIPOT File NOT FOUND: #{filename}"
      begin
        new_csv = CSV::Table::new([row], headers: csv.headers)
        dirname = File.dirname(filename)
        FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
        File.write(filename, new_csv.to_csv)
      rescue Exception => e
        puts "Error: #{e}"
      end
    end

    # VERY IMPORTANT!
    i = i - 1
  end
end

# MODEL/INSTANCE/TIMESTAMP
# Stores "part_instance" into databases corresponding station
def model_command(client, data)
  if data.length != 4
    puts "PLC SCRIPT: ERROR: WRONG LENGTH(4) for PART command"
    client.close
    return false
  end

  line_id = data[1] # "example: MET"
  station_name = data[2].strip.upcase
  model_data = data[3].strip.upcase.split("/")

  # unwrap model data
  model = model_data[0] if model_data.length > 0
  instance = model_data[1] if model_data.length > 1
  timestamp = model_data[2] if model_data.length > 2

  # Instance is not UNIQUE and TIMESTAMP is either
  # That is why onl MODEL-INSTANCE-TIMESTAMP in combination is unique
  # Must use Model-Instance-Timestance as "part_instance"
  part_instance = "#{model}_#{instance}_#{timestamp}"

  conn = PG.connect(:dbname => PG_DBNAME)

  # updating MODEL for correct DFT-QG instructions visualization
  if model 
    if station_name == "LINE" or station_name == "ST10"
      sql = "UPDATE lines SET default_model = '#{model}' WHERE line_identifier = '#{line_id}'"
      #puts "Update Line default model: #{sql}"
      res  = conn.exec(sql) 
    end
    
    if station_name != "LINE"
      sql = "UPDATE stations SET model = '#{model}' WHERE line_id IN (SELECT id from lines where line_identifier = '#{line_id}') and name = '#{station_name}'"
      #puts "Update Station model: #{sql}"
      res  = conn.exec(sql) 
    end
  end

  # updating part_instance for correct further data tracking
  if part_instance
    sql = "UPDATE stations SET part_instance = '#{part_instance}' WHERE line_id IN (SELECT id from lines where line_identifier = '#{line_id}') and name = '#{station_name}'"
    puts sql
    res  = conn.exec(sql) 
  end

  client.puts "OK"

  return true
end

### TRCK COMMAND
# TRCK:[LINE_IDENT]:[STATION_NAME]:any file name apendix:any file content
# example: TRCK:MET:ST10:SPINDLE 192.168.0.50 PASSED:abc,def,gef
# Purpose: To store tracking/Process data
# IMPORTANTE: track does not specify a part-sequence number. Only the station. In order to track correctly,
# the track command will verify WHAT "part_instance" is at station.
def trck_command(client, data)
  if data.length < 4 or data.length > 5
    puts "PLC SCRIPT: ERROR: WRONG LENGTH(4-5) for TRCK command"
    client.close
    return false
  end

  line_id = data[1]
  station_name = data[2]
  data[3] = data[3].gsub("__NL__", "\n")
  file_appendix = "#{data[3]}.#{data[3].include?("SPINDLE") ? "csv" : "txt"}"
  file_content = data[4] if data.length >= 5

  conn = PG.connect(:dbname => PG_DBNAME)

  res_line = check_line(conn, client, line_id)
  return false if res_line.nil?

  res_station = check_station(conn, client, line_id, station_name)
  return false if res_station.nil?

  part_instance = res_station[0]["part_instance"].to_s.strip
  part_instance = "NO_INSTANCE" if part_instance.empty?
  file_name = trck_file_path(res_line[0]["line_identifier"], res_station[0]["name"], part_instance, file_appendix, res_line[0]["trackingpath"])
  dirname = File.dirname(file_name)
  unless File.directory?(dirname)
    FileUtils.mkdir_p(dirname)
  end
  File.write(file_name, file_content)

  safe_puts(client, "OK")
  return true
end

########################################################################
###############                M A I N                 #################
########################################################################

PG_DBNAME = "abbjum_development"
PG_USERNAME = ""
PG_PASSWORD = ""

### LIST OF COMMANDS
# ECHO:any text here will be returned
# MODEL:[LINE_IDENT]:[STATION_NAME]:[NEWMODEL]  
# STOP
# PART:[LINE_IDENT]:[STATION_NAME]:[PART INSTANCE STRING]
# TRCK:[LINE_IDENT]:[STATION_NAME]:any file name apendix:any file content

# START TCP SERVER
port_to_listen_to = 8080
puts "PLC SCRIPT: starting to listen to: #{port_to_listen_to}"
server = TCPServer.open(port_to_listen_to)

loop {

  begin

    client = server.accept
    data = client.gets.gsub(/^(\W*)/,"").strip # filter out any non-alphanumerica characters until first char
    #puts 'PLC SCRIPT: --- receiving data at ' + Time.now.ctime + ' DATA=' + data
    puts "#{Time.now.ctime}==#{data.length}==#{data[0,100]}"

    # any client request is data formated as COMMAND:[data1]:[data2]:[etc...] 
    data = data.split(":")

    # wrong format. Even a command that sends no data, must end command with :
    if data.length == 0 
      client.close
      next
    end
    
    # command is universal
    command = data[0]

    ### STOP COMMAND
    ### will stop the script entirely
    ### and exit in order
    if command == "STOP"
      client.puts "PLC SCRIPT: STOP"
      client.close
      break # jump out of infinity-loop
    end

    ### HIPOT COMMAND
    # HIPOT:[LINE_IDENT]:...data... (may contain :)
    if command == "HIPOT"
      hipot_command(client, data)
      next
    end

    # PART COMMAND
    # Will Store the PART INSTANCE into the station's record and tracking
    # PART:[LINE_IDENT]:[STATION_NAME]:[PART INSTANCE STRING]
    # a) PART will trigger a MODEL command using the 'model' part of the string, storing MODEL and INSTANCE info for each station -> when INSTANCE NOT GIVEN, only MODEL to be updated
    # b) PART will trigger a TRCK command using the full string given if formated as "model/sequence/timestamp" and storing process data
    if command == "PART"
      puts "INSIDE PART.... #{data}"
      # CALL MODEL
      model_command(client, data)

      # CALL TRCK
      data[3] = "PART #{data[3]}"
      trck_command(client, data)
      next
    end

    ### TRCK COMMAND
    # TRCK:[LINE_IDENT]:[STATION_NAME]:any file name apendix:any file content
    # example: TRCK:MET:ST10:SPINDLE 192.168.0.50 PASSED:abc,def,gef
    # Purpose: To store tracking/Process data
    # IMPORTANTE: track does not specify a part-sequence number. Only the station. In order to track correctly,
    # the track command will verify WHAT "part_instance" is at station.
    if command == "TRCK"
      trck_command(client, data)
      next
    end

    ### ECHO COMMAND
    ### ECHO:any text here will be returned
    if command == "ECHO"
      if data.length != 2
        puts "ERROR: WRONG LENGTH(2) for ECHO command"
        client.close
        next
      end

      message = data[1]
      client.puts message
    end

    ### MODEL COMMAND: update model in database
    ### MODEL:[LINE_IDENT]:[STATION_NAME]:[NEWMODEL]  
    ### NEWMODEL => MODEL/INSTANCE/TIMESTAMP
    ###   -> when INSTANCE NOT GIVEN, only MODEL to be updated
    if command == "MODEL"
      # MODEL COMMAND
      model_command(client, data)
    end

    # AND ALWAYS CLOSE CLIENT CONNECTION
    client.close

  rescue Interrupt
    client.puts "NOK:Interrupt" if client
    client.close if client
    break #break the LOOP, and terminate script
  rescue Exception => e
    client.puts "NOK:#{e.message}" if client
    client.close if client
  end
}

puts "PLC SCRIPT: Exiting..."