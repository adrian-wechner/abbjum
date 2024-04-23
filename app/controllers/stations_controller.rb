class StationsController < ApplicationController
  before_action :get_line
  before_action :set_station, only: %i[ show edit update destroy ]

  # GET /stations or /stations.json
  def index
    @stations = @line.stations
    redirect_to @line
  end

  # GET /stations/1 or /stations/1.json
  def show
  end

  # GET /stations/new
  def new
    @station = @line.stations.build
  end

  # GET /stations/1/edit
  def edit
  end

  # POST /stations or /stations.json
  def create
    @station = @line.stations.build(station_params)

    respond_to do |format|
      if @station.save
        format.html { redirect_to line_path(@line), notice: "Station was successfully created." }
        format.json { render :show, status: :created, location: @station }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @station.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stations/1 or /stations/1.json
  def update
    respond_to do |format|
      if @station.update(station_params)
        format.html { redirect_to line_path(@line), notice: "Station was successfully updated." }
        format.json { render :show, status: :ok, location: @station }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @station.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stations/1 or /stations/1.json
  def destroy
    @station.destroy

    respond_to do |format|
      format.html { redirect_to line_url(@line), notice: "Station was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_station
      @station = @line.stations.find(params[:id])
    end

    def get_line
      @line = Line.find(params[:line_id])
    end

    # Only allow a list of trusted parameters through.
    def station_params
      params.require(:station).permit(:name, :line_id, :model, :operator_instructions, :ingersoll_ips, :hipot_ips, :part_instance)
    end
end
