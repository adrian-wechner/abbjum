require "application_system_test_case"

class StationsTest < ApplicationSystemTestCase
  setup do
    @station = stations(:one)
  end

  test "visiting the index" do
    visit stations_url
    assert_selector "h1", text: "Stations"
  end

  test "should create station" do
    visit stations_url
    click_on "New station"

    fill_in "Hipot ips", with: @station.hipot_ips
    fill_in "Ingersoll ips", with: @station.ingersoll_ips
    fill_in "Line", with: @station.line_id
    fill_in "Model", with: @station.model
    fill_in "Name", with: @station.name
    fill_in "Operator instructions", with: @station.operator_instructions
    click_on "Create Station"

    assert_text "Station was successfully created"
    click_on "Back"
  end

  test "should update Station" do
    visit station_url(@station)
    click_on "Edit this station", match: :first

    fill_in "Hipot ips", with: @station.hipot_ips
    fill_in "Ingersoll ips", with: @station.ingersoll_ips
    fill_in "Line", with: @station.line_id
    fill_in "Model", with: @station.model
    fill_in "Name", with: @station.name
    fill_in "Operator instructions", with: @station.operator_instructions
    click_on "Update Station"

    assert_text "Station was successfully updated"
    click_on "Back"
  end

  test "should destroy Station" do
    visit station_url(@station)
    click_on "Destroy this station", match: :first

    assert_text "Station was successfully destroyed"
  end
end
