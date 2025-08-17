require 'csv'

class SecretSantaService
  attr_reader :current_year, :previous_assignments
  
  def initialize(current_year = Date.current.year)
    @current_year = current_year
    @previous_assignments = load_previous_assignments
  end
  
  # Process CSV file and create employees
  def process_employee_csv(csv_file_path)
    employees = []
    
    begin
      # Try different encoding approaches
      csv_content = File.read(csv_file_path)
      
      # Try to detect and fix encoding issues
      unless csv_content.valid_encoding?
        csv_content = csv_content.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      end
      
      CSV.parse(csv_content, headers: true, liberal_parsing: true).each do |row|
        employee = Employee.find_or_create_by(email: row['Employee_EmailID']) do |emp|
          emp.name = row['Employee_Name']
        end
        employees << employee
      end
    rescue => e
      raise "Error processing CSV file: #{e.message}"
    end
    
    employees
  end
  
  # Process previous year's assignments CSV
  def process_previous_assignments_csv(csv_file_path)
    assignments = []
    
    begin
      # Try different encoding approaches
      csv_content = File.read(csv_file_path)
      
      # Try to detect and fix encoding issues
      unless csv_content.valid_encoding?
        csv_content = csv_content.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      end
      
      CSV.parse(csv_content, headers: true, liberal_parsing: true).each do |row|
        employee = Employee.find_by(email: row['Employee_EmailID'])
        secret_child = Employee.find_by(email: row['Secret_Child_EmailID'])
        
        if employee && secret_child
          assignment = SecretSantaAssignment.create!(
            employee: employee,
            secret_child: secret_child,
            year: current_year - 1
          )
          assignments << assignment
        end
      end
    rescue => e
      raise "Error processing previous assignments CSV: #{e.message}"
    end
    
    assignments
  end
  
  # Generate new Secret Santa assignments
  def generate_assignments
    employees = Employee.all.to_a
    return [] if employees.empty?
    
    # Clear existing assignments for current year
    SecretSantaAssignment.for_year(current_year).destroy_all
    
    assignments = []
    available_employees = employees.dup
    
    employees.each do |employee|
      # Find available secret child (not self, not assigned to anyone else, not from previous year)
      available_secret_children = available_employees.select do |candidate|
        candidate != employee && 
        !assignments.any? { |a| a.secret_child_id == candidate.id } &&
        !previous_assignment_exists?(employee, candidate)
      end
      
      if available_secret_children.empty?
        # If no valid candidates, reset and try again
        return generate_assignments_with_retry(employees)
      end
      
      # Randomly select from available candidates
      selected_child = available_secret_children.sample
      available_employees.delete(selected_child)
      
      assignment = SecretSantaAssignment.create!(
        employee: employee,
        secret_child: selected_child,
        year: current_year
      )
      assignments << assignment
    end
    
    assignments
  rescue => e
    raise "Error generating assignments: #{e.message}"
  end
  
  # Export assignments to CSV
  def export_assignments_to_csv
    assignments = SecretSantaAssignment.for_year(current_year).includes(:employee, :secret_child)
    
    CSV.generate(headers: true) do |csv|
      csv << ['Employee_Name', 'Employee_EmailID', 'Secret_Child_Name', 'Secret_Child_EmailID']
      
      assignments.each do |assignment|
        csv << [
          assignment.employee.name,
          assignment.employee.email,
          assignment.secret_child.name,
          assignment.secret_child.email
        ]
      end
    end
  end
  
  private
  
  def load_previous_assignments
    SecretSantaAssignment.for_year(current_year - 1).includes(:employee, :secret_child)
  end
  
  def previous_assignment_exists?(employee, secret_child)
    previous_assignments.any? do |assignment|
      assignment.employee_id == employee.id && assignment.secret_child_id == secret_child.id
    end
  end
  
  def generate_assignments_with_retry(employees, max_attempts = 100)
    max_attempts.times do
      begin
        return generate_assignments
      rescue
        # Clear and retry
        SecretSantaAssignment.for_year(current_year).destroy_all
      end
    end
    
    raise "Unable to generate valid assignments after #{max_attempts} attempts"
  end
end
