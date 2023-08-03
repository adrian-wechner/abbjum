require 'socket'
require 'pg'
require 'json'

PG_DBNAME = "abbjum_development"
PG_USERNAME = ""
PG_PASSWORD = ""

### LIST OF COMMANDS
# ECHO:any text here will be returned
# MODEL:[LINE_ID]:[STATION_NAME]:[NEWMODEL]  
# UPDATEDATA:[LINE_ID]:[MODEL]

# START TCP SERVER
port_to_listen_to = 8080
puts "starting to listen to: #{port_to_listen_to}"
server = TCPServer.open(port_to_listen_to)

# Each connection is a "server.accept"
loop {

  begin

    client = server.accept
    puts '--- receiving data at ' + Time.now.ctime
    data = client.gets

    puts "--- #{data}"

    # any client request is data formated as COMMAND:[data1]:[data2]:[etc...] 
    data = data.split(":")

    # wrong format. Even a command that sends no data, must end command with :
    if data.length == 0 
      client.close
      next
    end
    
    # command is universal
    command = data[0]

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

    ### UPDATEDATA COMMAND: adds MODEL to string and will get new copy of DFT/QG if avaiable
    ### UPDATEDATA:[LINE_ID]:[MODEL]
    if command == "UPDATEDATA"
      if data.length =! 3
        puts "ERROR: WRONG LEGNTH(3) for UPDATEDATA command"
        client.close
        next
      end

      line = data[1]
      model = data[2].to_s.strip.upcase

      conn = PG.connect(:dbname => PG_DBNAME)
      query = "SELECT * from lines where id = #{line};" 
      res  = conn.exec(query)

      # if the query affects 1 row, the query is clearly wrong. terminate client
      if res.cmd_tuples != 1
        error_msg = "ERROR: SELECT query did affect 1 row. Rather (#{res.cmb_tuples}) => #{query}"
        puts error_msg
        client.puts "NOK:#{error_msg}"
        client.close
        next
      end

      models = res[0]["station_models"]
      models = "{}" if models.to_s.strip.empty?
      models = JSON.parse(models)

      models["UPDATEDATA"] ||= []
      models["UPDATEDATA"] << model unless model.empty?

      res  = conn.exec("UPDATE lines SET station_models = '#{JSON.generate(models)}' WHERE id = #{line}") 

      client.puts "OK"
    end

    ### MODEL COMMAND: update model in database
    ### MODEL:[LINE_ID]:[STATION_NAME]:[NEWMODEL]  
    if command == "MODEL"

      if data.length != 4
        puts "ERROR: WRONG LENGTH(4) for MODEL command"
        client.close
        next
      end

      line = data[1].to_s.strip.upcase
      station = data[2].to_s.strip.upcase
      newmodel = data[3].to_s.strip.upcase

      conn = PG.connect(:dbname => PG_DBNAME)

      if station == "LINE"
        # When staiton name is LINE then we set the default model to newmode. Which is set
        # as part of the LINE table record. This can allow unofficial stations to already show
        # some relevant data. 
        # When to use: When FIRST station of line gets new model. Then would be good to use that
        # as the new default model for the entire line. Probably will be just right.
        res = conn.exec ("UPDATE lines SET default_model = '#{newmodel} WHERE id = #{line}")

      else # ANY STATION
        query = "SELECT * from stations where line_id = #{line} and name = #{station};" 
        res  = conn.exec(query)

        # if the query affects 1 row, the query is clearly wrong. terminate client
        if res.cmd_tuples != 1
          error_msg = "ERROR: SELECT query did affect 1 row. Rather (#{res.cmb_tuples}) => #{query}"
          puts error_msg
          client.puts "NOK:#{error_msg}"
          client.close
          next
        end

        res = conn.exec ("UPDATE stations SET model = '#{newmodel}' WHERE id = #{res[0]["id"]}")
      end
    end

    # AND ALWAYS CLOSE CLIENT CONNECTION
    client.close

  rescue Interrupt
    client.puts "NOK:Interrupt"
    client.close
    break #break the LOOP, and terminate script
  rescue Exception => e
    client.puts "NOK:#{e.message}"
    client.close
  end
}

puts "Exiting..."