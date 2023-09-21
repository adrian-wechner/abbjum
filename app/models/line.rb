class Line < ApplicationRecord
  has_one_attached :file, dependent: :destroy
  has_many :stations
  has_many :checklists
  has_many :checklist_records

 def translated_models_for_options
  # [['Option1', 1], ['Option2', 2], ...]
  arr = model_translation.upcase.split(",").map do |e|
    mt = e.strip.split(":") 
    ["#{mt.first.strip}-#{mt.last.strip}", mt.last.strip] 
  end
  arr.sort_by(&:last)
 end

  ### PATH FOR DFT,QG
  ### 3-OP-MET/001/3-OP-MET-001-ST1 tadadada.pdf
  ### 3-OP- => CONTENT PREFIX (DFT) 3-QA- => CONTENT PREFIX (QG)
  ### MET => LINE IDENTIFER
  ### 001 => MODEL SEQ NUMBER
  ### -ST1 => STATION IDENTIFER
  ### " xxxxx" => CUSTOM TEXT
  ### .pdf => FILE EXTENTION

  ### Return the right content prefix based on the content required
  ### This is fixed and hard coded, given by ABB plant 
  def content_prefix(content="DFT")
    case content.to_s.upcase
    when "DFT"
      "3-OP"
    when "QG"
      "3-QA"
    else
      "NOCONTENT"
    end
  end

  def location_path(location)
    case location
    when :remote
      remotepath
    when :local
      "public/displays"
    when :tracking
      trackingpath
    end
  end

  # => "3-OP-MET"
  def line_folder_name(content)
    "#{content_prefix(content)}-#{line_identifier}"
  end

  # => ~"3-OP-MET-001-ST10 *.pdf"
  def file_name_with_station_regex(content, model, station, file_extention)
    /#{content_prefix(content)}-#{line_identifier}-#{model}-#{station}(\s?.*)\.#{file_extention}/
  end

  # => ~"3-OP-MET-001*.pdf"
  def file_name_without_station_regex(content, model, file_extention)
    /#{content_prefix(content)}-#{line_identifier}-#{model}-.*\.#{file_extention}/
  end

  def file_name_clean(content, model, station)
    "#{content_prefix(content)}-#{line_identifier}-#{model}-#{station}"
  end

  def file_name_clean_with_extention(content, model, station, file_extention)
    "#{file_name_clean(content, model, station)}.#{file_extention}"
  end

  # => /.../3-OP-MET/
  def line_folder_path(location, content)
    #puts "DEBUG: line_folder_path => #{File.join(location_path(location), line_folder_name(content))}"
    File.join(location_path(location), line_folder_name(content))
  end

  # => /.../3-OP-MET/001/
  def line_model_folder_path(location, content, model) 
    #puts "DEBUG: line_model_folder_path (#{File.join(line_folder_path(location, content), model)})"
    File.join(line_folder_path(location, content), model)
  end

  # return ARRAY of files. Theory should only be 1 normally
  def line_model_all_station_files(location, content, model)
    Dir["#{line_model_folder_path(location, content, model)}/*"].match file_name_without_station_regex(content, model, "pdf")
  end

  def line_model_station_files(location, content, model, station)
    files = Dir["#{line_model_folder_path(location, content, model)}/*"]
    #puts "FILES DEBUG..... :#{files}"
    files.select {|f| f.match file_name_with_station_regex(content, model, station, "pdf") }
  end

  def line_model_station_pngs(location, content, model, station)
    files = Dir["#{line_model_folder_path(location, content, model)}/*"]
    files.select {|f| f.match file_name_with_station_regex(content, model, station, "png") }
  end

  def line_model_station_file_avaiable?(location, content, model, station)
    line_model_station_files(location, content, model, station).length > 0
  end
  

  # data in "model_translation"-field will be normalized
  # any ",", space or newline will be used to delimit
  # and then any content will be striped and UpperCased
  def get_model_translation_normalize
    delimiters = [',', "\n"]
    mt = model_translation.to_s.split(Regexp.union(delimiters))
    mt.reject! { |m| m.split(":").length != 2 }
    mt.map! do |m| 
      m = m.split(":")
      m[0] = m[0].strip.upcase
      m[1] = m[1].strip.upcase
      m
    end
    return mt 
  end

  # Using normalized data from the model_translation field
  # to be used to find the ABB Sequence Number of the model number
  def get_seq_from_model(model)
    mt = get_model_translation_normalize
    mt.each do |m|
      return m[0] if m[1] == model.strip.upcase
    end
    return "NOK" # not found, Not-OK
  end
end
