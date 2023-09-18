require "application_system_test_case"

class ChecklistRecordsTest < ApplicationSystemTestCase
  setup do
    @checklist_record = checklist_records(:one)
  end

  test "visiting the index" do
    visit checklist_records_url
    assert_selector "h1", text: "Checklist records"
  end

  test "should create checklist record" do
    visit checklist_records_url
    click_on "New checklist record"

    fill_in "Catalogue", with: @checklist_record.catalogue
    fill_in "Checkend", with: @checklist_record.checkend
    fill_in "Checklist", with: @checklist_record.checklist_id
    fill_in "Checkstart", with: @checklist_record.checkstart
    fill_in "Comments", with: @checklist_record.comments
    fill_in "Deviationcomment", with: @checklist_record.deviationcomment
    check "Deviationrun" if @checklist_record.deviationrun
    fill_in "Line", with: @checklist_record.line_id
    fill_in "Quantity", with: @checklist_record.quantity
    fill_in "Shift", with: @checklist_record.shift
    fill_in "User complete", with: @checklist_record.user_complete_id
    fill_in "User start", with: @checklist_record.user_start_id
    click_on "Create Checklist record"

    assert_text "Checklist record was successfully created"
    click_on "Back"
  end

  test "should update Checklist record" do
    visit checklist_record_url(@checklist_record)
    click_on "Edit this checklist record", match: :first

    fill_in "Catalogue", with: @checklist_record.catalogue
    fill_in "Checkend", with: @checklist_record.checkend
    fill_in "Checklist", with: @checklist_record.checklist_id
    fill_in "Checkstart", with: @checklist_record.checkstart
    fill_in "Comments", with: @checklist_record.comments
    fill_in "Deviationcomment", with: @checklist_record.deviationcomment
    check "Deviationrun" if @checklist_record.deviationrun
    fill_in "Line", with: @checklist_record.line_id
    fill_in "Quantity", with: @checklist_record.quantity
    fill_in "Shift", with: @checklist_record.shift
    fill_in "User complete", with: @checklist_record.user_complete_id
    fill_in "User start", with: @checklist_record.user_start_id
    click_on "Update Checklist record"

    assert_text "Checklist record was successfully updated"
    click_on "Back"
  end

  test "should destroy Checklist record" do
    visit checklist_record_url(@checklist_record)
    click_on "Destroy this checklist record", match: :first

    assert_text "Checklist record was successfully destroyed"
  end
end
