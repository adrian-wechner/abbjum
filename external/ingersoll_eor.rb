require 'socket'
require 'pg'

port = 1069 # -p [PORT] of CONTROLLER
host = 'localhost' # -h [HOST] of CONTROLLER
line_ident = "MET" # -l [LINE]
station = "ST10" # -s [STATION]

plc_script_host = "localhost"
plc_script_port = 8080

i = 0
while ARGV.length > i
  arg = ARGV[i]
  port = ARGV[(i+=1)] if arg == "-p"  && ARGV.length > (i+1)
  host = ARGV[(i+=1)] if arg == "-h"  && ARGV.length > (i+1)
  line = ARGV[(i+=1)] if arg == "-l"  && ARGV.length > (i+1)
  station = ARGV[(i+=1)] if arg == "-s"  && ARGV.length > (i+1)
  # dbname = ARGV[(i+=1)] if arg == "-d"  && ARGV.length > (i+1)
  i = i + 1
end

# conn = PG.connect(:dbname => dbname)
dbug = "[ISOLL #{host}]"
# debug values
puts "#{dbug} Open connection #{host}:#{port}"

# connect to server, send command and debug response
loop {
  begin
    ingersoll = TCPSocket.open(host, port)
  rescue Errno::ETIMEDOUT
    print "\n#{dbug} Reconnect..."
    retry
  rescue Interrupt
    break # end loop and exit
  rescue 
    retry # do nothing
  end

  puts "#{dbug} Connected"

  begin
    while (data = ingersoll.recv(8192)) && data.to_s.length > 0
      
      #### SEND DATA TO PLC SCRIPT Server

      # example: TRCK:MET:ST10:SPINDLE 192.168.0.50 PASSED:abc,def,gef
      puts "#{dbug} data: #{data}"

      # connect to server, send command and debug response
      csvheader = "Cycle Number,Power head Cycle Number,Spindle Number,Pset Number,Date,Time,Cycle Result,Peak Torque,Torque Result,Torque Units,Peak Angle,Angle Result,Shutdown Code,Peak Current,Cycle Time,Strategy type,Torque High Limit,Torque Low Limit,Angle High Limit,Angle Low Limit,Control Point,BCODE / VIN,Job Id,Step Number,Downshift Speed,Free Speed,TR,Dual Slope A High Limit,Dual Slope A Low Limit,Dual Slope B High Limit,Dual Slope B Low Limit,Gradient High Limit,Gradient Low Limit,Final Slope,Torque at Seat,Angle at Seat,Min Drag Torque,Peak Slope,Prevailing Torque Slope,Peak Cut In Torque,Peak Prevailing Torque,Average Prevailing Torque,Peak Drag Torque,Average Drag Torque,Total Batch Count,Current Batch Count,Tool Serial Number,Cp Result,Gradient Result,Dual Slope A Result,Dual Slope B Result,Unusual Fault,Motor Torque Constant Test,Free Speed Test,Max Tool Speed,Total Angle,Controller Cycle Number"
      command = "TRCK:#{line_ident}:#{station}:SPINDLE #{host}:#{csvheader}__NL__#{data.strip}"
      client = TCPSocket.open(plc_script_host, plc_script_port)
      client.puts(command)
      puts client.gets
      client.close

    end
    puts "\n#{dbug} Connection closed by Ingersoll Controller (#{host}:#{port})"
    ingersoll.close
  rescue Interrupt
    ingersoll.close if ingersoll && !ingersoll.closed?
    break # end loop and exit
  rescue
    print "#"
    ingersoll.close if ingersoll
  end
}
puts "#{dbug} INGERSOLL exiting..."