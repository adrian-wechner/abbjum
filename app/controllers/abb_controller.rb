require 'json'
require 'fileutils'
require 'pdftoimage'

class AbbController < ApplicationController

  layout "project", :only => [ :project ]


  def index
    @lines = Line.all
  end

  def select
    @line = Line.find_by(line_identifier: params[:l].upcase)
  end

  def project
    # EXTRACT DATA CONDITIONS
    # a) Not locally avaiable
    # b) when scanner detect different model number... so externally requested
    # c) when last data older than 24h

    # init params
    @images = []
    @what_to_show = :carousel # :carousel, :stations, :error
    @need_to_extract_data = false
    line_name = params[:l].to_s.strip.upcase
    station = params[:s].to_s.strip.upcase
    @content = params[:c].to_s.strip.upcase.split(",")
    @content = ["DFT"] if @content.empty?
    @line = Line.where(line_identifier: line_name).first
   
    # NO LINE => END HERE
    if @line.nil?
      render :error_line_not_found
      return
    end

    # NO STATION => END HERE
    if station.empty?
      render :error_station_missing
      return
    end

    json = JSON.parse(@line.station_models.to_s.empty? ? "{}" : @line.station_models)

    # supposed model
    @seq_model = nil
    @station = @line.stations.select { |st| st[:name] == station}.first
    @model = @station.model.to_s.strip.upcase if @station # IN CASE THERE IS NO STATION WITH THAT NAME, MUST CHECK FIRST
    @model = @line.default_model.to_s.upcase if @model.to_s.empty?

    # STATION NOT EXSITING vs STATION MISSING => Not found in DB vs Missing parameter
    if @station.nil?
      render :error_station_not_existing
      return
    end

    # Could not determin what model to look for
    # at least LINE default model should be selected, but wasn't
    if @model.empty?
      render :error_no_model
      return
    end


    @content.each do |content|

      puts "CONTENT: #{content}"

      if @line && station
        # Testing for "a) Not locall avaiable"
        @what_to_show = :error if @model.to_s.empty?
        @seq_model = @line.get_seq_from_model(@model)
        
        # a) choosen model. Check if avaiable locally
        if !@seq_model.to_s.empty?
          
          # If no model specific QG instruction avaiable in Remote folder
          # Quality gate MUST default to "GLOBAL" instruction sheets
          # must replace SEQ MODEL to be GLOBAL.
          if content == "QG"
            file = @line.line_model_station_files(:remote, content, @seq_model, station)
            @seq_model = "GLOBAL" if file.length.zero?
          end

          file = @line.line_model_station_files(:local, content, @seq_model, station)
          file.length > 0 ? file = file.first : file = "" 
          if !File.exist?(file)
            @need_to_extract_data = true
            puts "##### a) NEED: file not existing file(#{file})"
          else
            # c) if old PDF
            if File.mtime(file) < Time.now - (3600*24) ## check if 24h old
              puts "##### c) NEED: old file #{file} #{File.mtime(file)} #{Time.now - (3600*24)}"
              @need_to_extract_data = true 
            end
          end
        else
          @what_to_show = :error
        end

        # b) check for "updatedata"
        json["UPDATEDATA"] ||= []
        if json["UPDATEDATA"].include?(@model) 
          @need_to_extract_data = true 
          puts "##### b) NEED: in UPDATEDATA (#{@model})"
        end
        json["UPDATEDATA"].delete(@model)

        ### EXTRACTION
        if @need_to_extract_data
          # 1) delete existing station file if avaiable
          # 2) copy file from remote source
          # 3) extract sheets

          puts "DEBUG... NEED_TO_EXTRACT_DATA"

          # 1)
          @line.line_model_station_files(:local, content, @seq_model, station).each { |f| File.delete(f) }

          # 2)
          tmp = @line.line_model_folder_path(:local, content, @seq_model) 
          FileUtils.mkdir_p(tmp)

          puts "##### SERACH REMOTE PATH: #{@line.line_model_station_files(:remote, content, @seq_model, station)} content:#{content} seq:#{@seq_model} sta:#{station}"

          @line.line_model_station_files(:remote, content, @seq_model, station).each do |f|
            puts "##### COPYING #{f}"
            FileUtils.cp(f, File.join(@line.line_model_folder_path(:local, content, @seq_model), @line.file_name_clean_with_extention(content, @seq_model, station, "pdf")))
          end

          # 3)
          @line.line_model_station_files(:local, content, @seq_model, station).each do |file|
            PDFToImage.open(file).each_with_index do |image, page_number|
              # /.../3-OP-MET/001/3-OP-MET-001-ST10 lalala.pdf
              # /.../3-OP-MET/001/3-OP-MET-001-ST10-P0.png
              # /.../3-OP-MET/001/3-OP-MET-001-ST10-P1.png
              new_file = File.join(@line.line_model_folder_path(:local, content, @seq_model), "#{@line.file_name_clean(content, @seq_model, station)}-P#{page_number}.png")
              image.r(300).save(new_file)
            end
          end

        end

        # UPDATEDATA might update
        @line.station_models = JSON.generate(json)
        @line.save!

      end
      @images.concat @line.line_model_station_pngs(:local, content, @seq_model, station)
      puts "IMAGES: #{@images}"
      @images.map! { |i| i[0,6] == "public" ? i[6,100] : i } # remove "public" from the beginning of string
    end

  end
end
