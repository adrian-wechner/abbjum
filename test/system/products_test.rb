require "application_system_test_case"

class ProductsTest < ApplicationSystemTestCase
  setup do
    @product = products(:one)
  end

  test "visiting the index" do
    visit products_url
    assert_selector "h1", text: "Products"
  end

  test "should create product" do
    visit products_url
    click_on "New product"

    fill_in "Cam metric1", with: @product.cam_metric1
    fill_in "Cam metric2", with: @product.cam_metric2
    fill_in "Cam metric3", with: @product.cam_metric3
    fill_in "Cam metric4", with: @product.cam_metric4
    fill_in "Cam metric5", with: @product.cam_metric5
    fill_in "Cam metric6", with: @product.cam_metric6
    fill_in "Cam metric7", with: @product.cam_metric7
    fill_in "Cam metric8", with: @product.cam_metric8
    fill_in "Catalog", with: @product.catalog
    fill_in "Line", with: @product.line_id
    fill_in "Seq", with: @product.seq
    fill_in "Status", with: @product.status
    click_on "Create Product"

    assert_text "Product was successfully created"
    click_on "Back"
  end

  test "should update Product" do
    visit product_url(@product)
    click_on "Edit this product", match: :first

    fill_in "Cam metric1", with: @product.cam_metric1
    fill_in "Cam metric2", with: @product.cam_metric2
    fill_in "Cam metric3", with: @product.cam_metric3
    fill_in "Cam metric4", with: @product.cam_metric4
    fill_in "Cam metric5", with: @product.cam_metric5
    fill_in "Cam metric6", with: @product.cam_metric6
    fill_in "Cam metric7", with: @product.cam_metric7
    fill_in "Cam metric8", with: @product.cam_metric8
    fill_in "Catalog", with: @product.catalog
    fill_in "Line", with: @product.line_id
    fill_in "Seq", with: @product.seq
    fill_in "Status", with: @product.status
    click_on "Update Product"

    assert_text "Product was successfully updated"
    click_on "Back"
  end

  test "should destroy Product" do
    visit product_url(@product)
    click_on "Destroy this product", match: :first

    assert_text "Product was successfully destroyed"
  end
end
