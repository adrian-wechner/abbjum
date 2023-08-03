require 'socket'

port = 8080 # -p [PORT]
host = 'localhost' # -h [HOST]
command = "ECHO:Hello" # -c [COMMAND]

i = 0
while ARGV.length > i
  arg = ARGV[i]
  port = ARGV[i+1] if arg == "-p"  && ARGV.length > (i+1)
  host = ARGV[i+1] if arg == "-h"  && ARGV.length > (i+1)
  
  # -c will take all remaining ARGV and leave the while loop
  if arg == "-c"  && ARGV.length > (i+1)
    command = ARGV.slice(i+1, 100).join(" ") 
    break
  end
  i = i + 1
end

# debug values
puts "#{host}:#{port} => #{command}"

# connect to server, send command and debug response
server = TCPSocket.open(host, port)
server.puts(command)
puts server.gets
server.close
