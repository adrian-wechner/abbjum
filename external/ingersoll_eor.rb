require 'socket'
conn = PG.connect(:dbname => PG_DBNAME)

port = 1069 # -p [PORT]
host = 'localhost' # -h [HOST]
line_ident = ""

s = nil

i = 0
while ARGV.length > i
  arg = ARGV[i]
  port = ARGV[i+1] if arg == "-p"  && ARGV.length > (i+1)
  host = ARGV[i+1] if arg == "-h"  && ARGV.length > (i+1)
  i = i + 1
end

# debug values
print "Open connection #{host}:#{port}..."

# connect to server, send command and debug response
loop {
  begin
    ingersoll = TCPSocket.open(host, port)
  rescue Errno::ETIMEDOUT
    print "\nReconnect..."
    retry
  rescue 
    # do nothing
    retry
  end

  puts "Connected"

  begin
    while (data = ingersoll.recv(8192)) && data.to_s.length > 0
      puts data
    end
    puts "\nConnection closed by Ingersoll Controller (#{host}:#{port})"
    ingersoll.close
  rescue
    print "#"
    ingersoll.close if ingersoll
  end
}

puts "INGERSOLL exiting..."