require 'pg'
require 'fileutils'
require 'yaml'

PG_DBNAME = "abbjum_development"
PG_USERNAME = ""
PG_PASSWORD = ""



def rootTrackingFolder()
  "/home/abb/Documents/TRACKING"
end

def rootCamFolders()
  ["/home/abb/Documents/CAM40/CAM2","/home/abb/Documents/CAM90/CAM1"]
end

def getImagesInFolder()
  files = []
  rootCamFolders.each { |folder| files = files.concat(Dir["#{folder}/*"]) }
  #files.each { |f| puts f}
  return files
end

loop {

  begin

    # Sleep for a few seconds. Non time critial. Just give it some time.
    sleep 5

    appConf = YAML.load_file('/home/abb/Documents/abbjum.yaml')

    # Get Images, otherwise, wait next loop
    images = getImagesInFolder()
    next if images.length.zero?

    # Get Part Instance
    conn = PG.connect(:dbname => PG_DBNAME)
    sql = "SELECT id, part_instance from stations where name = '#{appConf["camstation"]}'"
    res  = conn.exec(sql)
    sta_part_instance = res[0]["part_instance"].to_s.strip


    ## GET FULL FOLDER PATH BASED ON PART INSTANCE
    abb_timestamp = sta_part_instance.split("_").last

    # YEAR
    year_digit = abb_timestamp[3]
    year = "202#{year_digit}"
    year = "203#{year_digit}" if Time.now.year >= 2030

    # WEEK
    week_digits = abb_timestamp[4..5]

    # WEEK-DAY
    week_day_digit = abb_timestamp[7]

    #### FULL SUB-STRUCTURE FOLDER PATH TO PART AND STATION
    folderPath = "#{appConf["camline"]}/#{year}/#{week_digits}/#{week_day_digit}/#{sta_part_instance}/#{appConf["camstation"]}"
    #"#{Time.now.strftime("%Y-%m-%d %H-%M-%S")} #{line_ident} #{station_name} #{part_instance} #{file_appendix.gsub("/", "-")}"

    ## Move File to folderPath
    images.each do |im|

      newFileName = "#{Time.now.strftime("%Y-%m-%d %H-%M-%S")} #{appConf["camline"]} #{appConf["camstation"]} #{abb_timestamp[1]} IMAGE #{sta_part_instance}.jpg"
      puts "IMAGES: #{im} -> #{folderPath}/#{newFileName}"
      FileUtils.mv(im, "#{rootTrackingFolder}/#{folderPath}/#{newFileName}")
    end


  rescue Interrupt
    puts "NOK:Interrupt" 
    break #break the LOOP, and terminate script
  rescue Exception => e
    puts "NOK:#{e.message}"
  end
}