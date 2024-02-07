class ChecklistsController < ApplicationController
  before_action :set_checklist, only: %i[ show edit update destroy ]
  skip_before_action :verify_authenticity_token, only: %i[ updateOrdernums ]

  # GET /checklists or /checklists.json
  def index
    @checklists = Checklist.joins(:line)
    @checklist_records = ChecklistRecord.order(created_at: :desc).where("checkend = NULL OR (checklist_records.created_at > (now() - interval '1 week'))").joins(:line)
  end

  # GET /checklists/1 or /checklists/1.json
  def show
  end

  # GET /checklists/new
  def new
    @checklist = Checklist.new
  end

  # GET /checklists/1/edit
  def edit
  end

  # POST /checklists/1/updateOrdernums
  def updateOrdernums

    items = JSON.parse(params[:checklist_items])
    items.each do |item|
      ChecklistItem.find(item[0]).update(ordernum: item[1])
    end



    respond_to do |format|
      format.json { render json: '{"status":"ok"}', status: :ok }
    end
  end

  # POST /checklists or /checklists.json
  def create
    @checklist = Checklist.new(checklist_params)

    respond_to do |format|
      if @checklist.save
        format.html { redirect_to checklist_url(@checklist), notice: "Checklist was successfully created." }
        format.json { render :show, status: :created, location: @checklist }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @checklist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /checklists/1 or /checklists/1.json
  def update
    respond_to do |format|
      if @checklist.update(checklist_params)
        format.html { redirect_to checklist_url(@checklist), notice: "Checklist was successfully updated." }
        format.json { render :show, status: :ok, location: @checklist }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @checklist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checklists/1 or /checklists/1.json
  def destroy
    @checklist.destroy

    respond_to do |format|
      format.html { redirect_to checklists_url, notice: "Checklist was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_checklist
      @checklist = Checklist.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def checklist_params
      params.require(:checklist).permit(:line_id, :name, :title)
    end
end
