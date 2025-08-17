require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  test "should generate slug on creation" do
    employee = Employee.create!(name: "Unique Test Name", email: "unique.test@example.com")
    assert_equal "unique-test-name", employee.slug
  end

  test "should generate unique slug when duplicate names exist" do
    Employee.create!(name: "Duplicate Name Test", email: "duplicate1.test@example.com")
    employee2 = Employee.create!(name: "Duplicate Name Test", email: "duplicate2.test@example.com")
    assert_equal "duplicate-name-test-1", employee2.slug
  end

  test "should handle special characters in names" do
    employee = Employee.create!(name: "Special Chars Test", email: "special.chars@example.com")
    assert_equal "special-chars-test", employee.slug
  end

  test "to_param should return slug" do
    employee = Employee.create!(name: "Param Test Name", email: "param.test@example.com")
    assert_equal employee.slug, employee.to_param
  end

  test "should find employee by slug" do
    employee = Employee.create!(name: "Find Test Name", email: "find.test@example.com")
    found_employee = Employee.find_by_slug(employee.slug)
    assert_equal employee, found_employee
  end
end
