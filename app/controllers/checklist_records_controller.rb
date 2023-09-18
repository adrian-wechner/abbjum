class ChecklistRecordsController < ApplicationController
  before_action :set_checklist_record, only: %i[ show edit update destroy ]

  # GET /checklist_records or /checklist_records.json
  def index
    @checklist_records = ChecklistRecord.all
  end

  # GET /checklist_records/1 or /checklist_records/1.json
  def show
  end

  # GET /checklist_records/new
  def new
    @checklist_record = ChecklistRecord.new
  end

  # GET /checklist_records/1/edit
  def edit
  end

  # POST /checklist_records or /checklist_records.json
  def create
    @checklist_record = ChecklistRecord.new(checklist_record_params)

    respond_to do |format|
      if @checklist_record.save
        format.html { redirect_to checklist_record_url(@checklist_record), notice: "Checklist record was successfully created." }
        format.json { render :show, status: :created, location: @checklist_record }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @checklist_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /checklist_records/1 or /checklist_records/1.json
  def update
    respond_to do |format|
      if @checklist_record.update(checklist_record_params)
        format.html { redirect_to checklist_record_url(@checklist_record), notice: "Checklist record was successfully updated." }
        format.json { render :show, status: :ok, location: @checklist_record }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @checklist_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checklist_records/1 or /checklist_records/1.json
  def destroy
    @checklist_record.destroy

    respond_to do |format|
      format.html { redirect_to checklist_records_url, notice: "Checklist record was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_checklist_record
      @checklist_record = ChecklistRecord.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def checklist_record_params
      params.require(:checklist_record).permit(:checklist_id, :user_start_id, :user_complete_id, :line_id, :catalogue, :checkstart, :checkend, :quantity, :shift, :comments, :deviationrun, :deviationcomment)
    end
end
