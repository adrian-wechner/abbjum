require 'json'

class LinesController < ApplicationController
  before_action :set_line, only: %i[ show edit update destroy model ]

  # GET /lines or /lines.json
  def index
    @lines = Line.all
  end

  # GET /lines/1 or /lines/1.json
  def show
  end

  # GET /lines/new
  def new
    @line = Line.new
  end

  # GET /lines/1/edit
  def edit
  end

  # GET /lines(/:id)/model(/:station)(/:newmodel)
  def model
    # in the "models" fields, a JSON is stored with the models information. JSON format:
    # { "STATIONS": {"ST10": "...", "ST20": "...", etc... }}

    # INIT variables
    json_string = @line.station_models.to_s 
    json = {}

    # NORMALIZE PARMAS
    params[:station] = params[:station].to_s.strip.upcase
    params[:newmodel] = params[:newmodel].to_s.strip.upcase

    # SPECIAL FOCUS ON "DELETE"
    # DELETE alone will empty out the whole string
    # DELETE on a station will delete the station onlyo
    if params[:station] == "DELETE"
      @line.station_models = ""
      @line.save!
    else 


      begin
        json = JSON.parse(json_string)
      rescue JSON::ParserError
        json_string = "{}"
        json = JSON.parse(json_string)
      end

      if !params[:newmodel].empty?
        st = "LINE"
        st = params[:station] if !params[:station].empty?

        json["STATIONS"] ||= {}
        json["STATIONS"][st] = params[:newmodel]
        json["STATIONS"].delete(st) if params[:newmodel] == "DELETE"
        
        @line.station_models = JSON.generate(json)
        @line.save!
      end
    end

    respond_to do |format|
      format.html
      format.text do 
        if params[:station].empty?
          puts "no station"
          render :plain => @line.station_models
        else
          puts "with station #{params[:station]}"
          puts json
          render :plain => json["STATIONS"][params[:station]]
        end
      end
    end
  end

  # POST /lines or /lines.json
  def create
    @line = Line.new(line_params)

    respond_to do |format|
      if @line.save
        format.html { redirect_to line_url(@line), notice: "Line was successfully created." }
        format.json { render :show, status: :created, location: @line }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @line.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lines/1 or /lines/1.json
  def update
    respond_to do |format|
      if @line.update(line_params)
        format.html { redirect_to line_url(@line), notice: "Line was successfully updated." }
        format.json { render :show, status: :ok, location: @line }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @line.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lines/1 or /lines/1.json
  def destroy
    @line.destroy

    respond_to do |format|
      format.html { redirect_to lines_url, notice: "Line was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_line
      @line = Line.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def line_params
      params.require(:line).permit(:name, :line_identifier, :model_translation, :localpath, :remotepath, :trackingpath, :file, :default_model)
    end
end
