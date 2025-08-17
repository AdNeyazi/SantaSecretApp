class EmployeesController < ApplicationController
  def show
    @employee = Employee.find_by_slug(params[:slug])
    
    if @employee.nil?
      redirect_to root_path, alert: 'Employee not found'
    end
  end
end
