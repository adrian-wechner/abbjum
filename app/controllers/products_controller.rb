require 'csv'

class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
    @products = Product.all
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to product_url(@product), notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to product_url(@product), notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /products/spreadsheet
  def spreadsheet
  end

  # PATCH /products/update_product_xls
  def update_products_xls

    # open CSV and normalizes headers to be lowercase
    CSV.foreach(params[:productfile], headers: true, header_converters: [:downcase, :symbol]) do |row|
      
      prod = Product.where(catalog: row[:catalogo])
      if prod.length.zero?
        Product.create(line_id: params[:line_id], catalog: row[:catalogo], seq: row[:seq], status: (row[:activo].to_s.length.zero? ? 0 : 1), cam_metric1: row[:metric1].to_i, cam_metric2: row[:metric2].to_i, cam_metric3: row[:metric3].to_i, cam_metric4: row[:metric4].to_i, cam_metric5: row[:metric5].to_i, cam_metric6: row[:metric6].to_i, cam_metric7: row[:metric7].to_i, cam_metric8: row[:metric8].to_i)
      else
        prod = prod.first
        prod.seq = row[:seq]
        prod.status = (row[:activo].to_s.length.zero? ? 0 : 1)
        prod.cam_metric1 = row[:metric1].to_i
        prod.cam_metric2 = row[:metric2].to_i
        prod.cam_metric3 = row[:metric3].to_i
        prod.cam_metric4 = row[:metric4].to_i
        prod.cam_metric5 = row[:metric5].to_i
        prod.cam_metric6 = row[:metric6].to_i
        prod.cam_metric7 = row[:metric7].to_i
        prod.cam_metric8 = row[:metric8].to_i
        prod.save
      end
      # puts prod.inspect

      #puts "HEY #{row.inspect} CAT?#{row[:catalogo]} #{row[0]} #{row.headers}"
    end

    respond_to do |format|
      format.html { redirect_to products_path, notice: "Product was successfully updated." }
      format.json { render :show, status: :ok, location: @product }
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy

    respond_to do |format|
      format.html { redirect_to products_url, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(:productfile, :line_id, :seq, :catalog, :status, :cam_metric1, :cam_metric2, :cam_metric3, :cam_metric4, :cam_metric5, :cam_metric6, :cam_metric7, :cam_metric8)
    end
end
