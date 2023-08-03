require "test_helper"

class AbbControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get abb_index_url
    assert_response :success
  end
end
