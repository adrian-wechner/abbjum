require "test_helper"

class ChecklistRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @checklist_record = checklist_records(:one)
  end

  test "should get index" do
    get checklist_records_url
    assert_response :success
  end

  test "should get new" do
    get new_checklist_record_url
    assert_response :success
  end

  test "should create checklist_record" do
    assert_difference("ChecklistRecord.count") do
      post checklist_records_url, params: { checklist_record: { catalogue: @checklist_record.catalogue, checkend: @checklist_record.checkend, checklist_id: @checklist_record.checklist_id, checkstart: @checklist_record.checkstart, comments: @checklist_record.comments, deviationcomment: @checklist_record.deviationcomment, deviationrun: @checklist_record.deviationrun, line_id: @checklist_record.line_id, quantity: @checklist_record.quantity, shift: @checklist_record.shift, user_complete_id: @checklist_record.user_complete_id, user_start_id: @checklist_record.user_start_id } }
    end

    assert_redirected_to checklist_record_url(ChecklistRecord.last)
  end

  test "should show checklist_record" do
    get checklist_record_url(@checklist_record)
    assert_response :success
  end

  test "should get edit" do
    get edit_checklist_record_url(@checklist_record)
    assert_response :success
  end

  test "should update checklist_record" do
    patch checklist_record_url(@checklist_record), params: { checklist_record: { catalogue: @checklist_record.catalogue, checkend: @checklist_record.checkend, checklist_id: @checklist_record.checklist_id, checkstart: @checklist_record.checkstart, comments: @checklist_record.comments, deviationcomment: @checklist_record.deviationcomment, deviationrun: @checklist_record.deviationrun, line_id: @checklist_record.line_id, quantity: @checklist_record.quantity, shift: @checklist_record.shift, user_complete_id: @checklist_record.user_complete_id, user_start_id: @checklist_record.user_start_id } }
    assert_redirected_to checklist_record_url(@checklist_record)
  end

  test "should destroy checklist_record" do
    assert_difference("ChecklistRecord.count", -1) do
      delete checklist_record_url(@checklist_record)
    end

    assert_redirected_to checklist_records_url
  end
end
