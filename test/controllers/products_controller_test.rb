require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
  end

  test "should get index" do
    get products_url
    assert_response :success
  end

  test "should get new" do
    get new_product_url
    assert_response :success
  end

  test "should create product" do
    assert_difference("Product.count") do
      post products_url, params: { product: { cam_metric1: @product.cam_metric1, cam_metric2: @product.cam_metric2, cam_metric3: @product.cam_metric3, cam_metric4: @product.cam_metric4, cam_metric5: @product.cam_metric5, cam_metric6: @product.cam_metric6, cam_metric7: @product.cam_metric7, cam_metric8: @product.cam_metric8, catalog: @product.catalog, line_id: @product.line_id, seq: @product.seq, status: @product.status } }
    end

    assert_redirected_to product_url(Product.last)
  end

  test "should show product" do
    get product_url(@product)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_url(@product)
    assert_response :success
  end

  test "should update product" do
    patch product_url(@product), params: { product: { cam_metric1: @product.cam_metric1, cam_metric2: @product.cam_metric2, cam_metric3: @product.cam_metric3, cam_metric4: @product.cam_metric4, cam_metric5: @product.cam_metric5, cam_metric6: @product.cam_metric6, cam_metric7: @product.cam_metric7, cam_metric8: @product.cam_metric8, catalog: @product.catalog, line_id: @product.line_id, seq: @product.seq, status: @product.status } }
    assert_redirected_to product_url(@product)
  end

  test "should destroy product" do
    assert_difference("Product.count", -1) do
      delete product_url(@product)
    end

    assert_redirected_to products_url
  end
end
