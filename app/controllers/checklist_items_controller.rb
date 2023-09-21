class ChecklistItemsController < ApplicationController
  before_action :set_checklist_item, only: %i[ show edit update destroy ]

  # GET /checklist_items or /checklist_items.json
  def index
    @checklist_items = ChecklistItem.all
  end

  # GET /checklist_items/1 or /checklist_items/1.json
  def show
  end

  # GET /checklist_items/new
  def new
    @checklist_item = ChecklistItem.new
  end

  # GET /checklist_items/1/edit
  def edit
  end

  # POST /checklist_items or /checklist_items.json
  def create
    @checklist_item = ChecklistItem.new(checklist_item_params)

    respond_to do |format|
      if @checklist_item.save
        format.html { redirect_to checklist_item_url(@checklist_item), notice: "Checklist item was successfully created." }
        format.json { render :show, status: :created, location: @checklist_item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @checklist_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /checklist_items/1 or /checklist_items/1.json
  def update
    respond_to do |format|
      if @checklist_item.update(checklist_item_params)
        format.html { redirect_to checklist_item_url(@checklist_item), notice: "Checklist item was successfully updated." }
        format.json { render :show, status: :ok, location: @checklist_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @checklist_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checklist_items/1 or /checklist_items/1.json
  def destroy
    @checklist_item.destroy

    respond_to do |format|
      format.html { redirect_to checklist_items_url, notice: "Checklist item was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_checklist_item
      @checklist_item = ChecklistItem.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def checklist_item_params
      params.require(:checklist_item).permit(:checklist_id, :ident, :label, :primaryanswers, :primaryanswertype, :itemtype, :ordernum, :secondaryanswertype)
    end
end
