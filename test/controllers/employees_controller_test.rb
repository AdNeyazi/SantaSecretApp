require "test_helper"

class EmployeesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @employee = employees(:one)
  end

  test "should get show" do
    get employee_url(@employee)
    assert_response :success
  end

  test "should redirect to root if employee not found" do
    get employee_url("non-existent-slug")
    assert_redirected_to root_path
  end
end
