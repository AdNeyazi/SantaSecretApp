require 'rails_helper'

RSpec.describe SecretSantaService do
  let(:current_year) { Date.current.year }
  let(:service) { SecretSantaService.new(current_year) }
  let(:temp_dir) { Dir.mktmpdir }
  
  after(:each) do
    FileUtils.remove_entry temp_dir
  end

  describe '#initialize' do
    it 'sets current year' do
      expect(service.current_year).to eq(current_year)
    end

    it 'loads previous assignments' do
      expect(service.previous_assignments).to be_a(ActiveRecord::Relation)
    end
  end

  describe '#process_employee_csv' do
    let(:csv_path) { File.join(temp_dir, 'employees.csv') }
    
    before do
      CSV.open(csv_path, 'w') do |csv|
        csv << ['Employee_Name', 'Employee_EmailID']
        csv << ['John Doe', 'john.doe@example.com']
        csv << ['Jane Smith', 'jane.smith@example.com']
      end
    end

    it 'creates employees from CSV' do
      expect {
        service.process_employee_csv(csv_path)
      }.to change(Employee, :count).by(2)
    end

    it 'returns array of employees' do
      employees = service.process_employee_csv(csv_path)
      expect(employees).to be_an(Array)
      expect(employees.length).to eq(2)
      expect(employees.first).to be_a(Employee)
    end

    it 'handles duplicate emails gracefully' do
      # Create first time
      service.process_employee_csv(csv_path)
      initial_count = Employee.count
      
      # Process again - should not create duplicates
      service.process_employee_csv(csv_path)
      expect(Employee.count).to eq(initial_count)
    end

    it 'raises error for invalid CSV' do
      invalid_csv = File.join(temp_dir, 'invalid.csv')
      File.write(invalid_csv, 'invalid,csv,data')
      
      expect {
        service.process_employee_csv(invalid_csv)
      }.to raise_error(RuntimeError, /Error processing CSV file/)
    end
  end

  describe '#process_previous_assignments_csv' do
    let(:csv_path) { File.join(temp_dir, 'previous.csv') }
    let!(:employee1) { create(:employee, email: 'john.doe@example.com') }
    let!(:employee2) { create(:employee, email: 'jane.smith@example.com') }
    
    before do
      CSV.open(csv_path, 'w') do |csv|
        csv << ['Employee_Name', 'Employee_EmailID', 'Secret_Child_Name', 'Secret_Child_EmailID']
        csv << ['John Doe', 'john.doe@example.com', 'Jane Smith', 'jane.smith@example.com']
      end
    end

    it 'creates previous assignments from CSV' do
      expect {
        service.process_previous_assignments_csv(csv_path)
      }.to change(SecretSantaAssignment, :count).by(1)
    end

    it 'sets correct year for previous assignments' do
      service.process_previous_assignments_csv(csv_path)
      assignment = SecretSantaAssignment.last
      expect(assignment.year).to eq(current_year - 1)
    end

    it 'returns array of assignments' do
      assignments = service.process_previous_assignments_csv(csv_path)
      expect(assignments).to be_an(Array)
      expect(assignments.first).to be_a(SecretSantaAssignment)
    end
  end

  describe '#generate_assignments' do
    let!(:employees) { create_list(:employee, 3) }

    it 'creates assignments for all employees' do
      expect {
        service.generate_assignments
      }.to change(SecretSantaAssignment, :count).by(3)
    end

    it 'sets correct year for assignments' do
      service.generate_assignments
      assignments = SecretSantaAssignment.for_year(current_year)
      expect(assignments.count).to eq(3)
      assignments.each do |assignment|
        expect(assignment.year).to eq(current_year)
      end
    end

    it 'ensures no employee is assigned to themselves' do
      service.generate_assignments
      assignments = SecretSantaAssignment.for_year(current_year)
      assignments.each do |assignment|
        expect(assignment.employee_id).not_to eq(assignment.secret_child_id)
      end
    end

    it 'ensures each employee has exactly one secret child' do
      service.generate_assignments
      employee_ids = SecretSantaAssignment.for_year(current_year).pluck(:employee_id)
      expect(employee_ids.uniq).to match_array(employee_ids)
    end

    it 'ensures each secret child is assigned to only one employee' do
      service.generate_assignments
      secret_child_ids = SecretSantaAssignment.for_year(current_year).pluck(:secret_child_id)
      expect(secret_child_ids.uniq).to match_array(secret_child_ids)
    end

    it 'avoids previous year assignments' do
      # Create previous year assignment
      create(:secret_santa_assignment, 
             employee: employees.first, 
             secret_child: employees.second, 
             year: current_year - 1)
      
      service.generate_assignments
      current_assignment = SecretSantaAssignment.for_year(current_year).find_by(employee: employees.first)
      expect(current_assignment.secret_child).not_to eq(employees.second)
    end

    it 'returns empty array when no employees exist' do
      Employee.destroy_all
      expect(service.generate_assignments).to eq([])
    end

    it 'clears existing assignments for current year' do
      # Create existing assignment
      create(:secret_santa_assignment, 
             employee: employees.first, 
             secret_child: employees.second, 
             year: current_year)
      
      expect {
        service.generate_assignments
      }.to change(SecretSantaAssignment.for_year(current_year), :count).to(3)
    end
  end

  describe '#export_assignments_to_csv' do
    let!(:employee1) { create(:employee, name: 'John Doe', email: 'john.doe@example.com') }
    let!(:employee2) { create(:employee, name: 'Jane Smith', email: 'jane.smith@example.com') }
    let!(:assignment) do
      create(:secret_santa_assignment, 
             employee: employee1, 
             secret_child: employee2, 
             year: current_year)
    end

    it 'generates CSV with correct headers' do
      csv_data = service.export_assignments_to_csv
      expect(csv_data).to include('Employee_Name,Employee_EmailID,Secret_Child_Name,Secret_Child_EmailID')
    end

    it 'includes assignment data' do
      csv_data = service.export_assignments_to_csv
      expect(csv_data).to include('John Doe,john.doe@example.com,Jane Smith,jane.smith@example.com')
    end

    it 'handles empty assignments gracefully' do
      SecretSantaAssignment.destroy_all
      csv_data = service.export_assignments_to_csv
      expect(csv_data).to include('Employee_Name,Employee_EmailID,Secret_Child_Name,Secret_Child_EmailID')
      # Should only have headers, no data rows
      expect(csv_data.lines.count).to eq(1)
    end
  end

  describe 'private methods' do
    describe '#previous_assignment_exists?' do
      let(:employee1) { create(:employee) }
      let(:employee2) { create(:employee) }
      let!(:previous_assignment) do
        create(:secret_santa_assignment, 
               employee: employee1, 
               secret_child: employee2, 
               year: current_year - 1)
      end

      it 'returns true when previous assignment exists' do
        expect(service.send(:previous_assignment_exists?, employee1, employee2)).to be true
      end

      it 'returns false when no previous assignment exists' do
        employee3 = create(:employee)
        expect(service.send(:previous_assignment_exists?, employee1, employee3)).to be false
      end
    end
  end
end
