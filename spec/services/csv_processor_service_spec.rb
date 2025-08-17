require 'rails_helper'

RSpec.describe CsvProcessorService do
  let(:temp_dir) { Dir.mktmpdir }
  
  after(:each) do
    FileUtils.remove_entry temp_dir
  end

  describe '.validate_employee_csv' do
    let(:csv_path) { File.join(temp_dir, 'employees.csv') }

    context 'with valid CSV' do
      before do
        CSV.open(csv_path, 'w') do |csv|
          csv << ['Employee_Name', 'Employee_EmailID']
          csv << ['John Doe', 'john.doe@example.com']
          csv << ['Jane Smith', 'jane.smith@example.com']
        end
      end

      it 'returns empty array for valid CSV' do
        errors = CsvProcessorService.validate_employee_csv(csv_path)
        expect(errors).to be_empty
      end
    end

    context 'with missing Employee_Name' do
      before do
        CSV.open(csv_path, 'w') do |csv|
          csv << ['Employee_Name', 'Employee_EmailID']
          csv << ['', 'john.doe@example.com']
          csv << ['Jane Smith', 'jane.smith@example.com']
        end
      end

      it 'returns error for missing name' do
        errors = CsvProcessorService.validate_employee_csv(csv_path)
        expect(errors).to include('Line 2: Employee_Name is required')
      end
    end

    context 'with missing Employee_EmailID' do
      before do
        CSV.open(csv_path, 'w') do |csv|
          csv << ['Employee_Name', 'Employee_EmailID']
          csv << ['John Doe', '']
          csv << ['Jane Smith', 'jane.smith@example.com']
        end
      end

      it 'returns error for missing email' do
        errors = CsvProcessorService.validate_employee_csv(csv_path)
        expect(errors).to include('Line 2: Employee_EmailID is required')
      end
    end

    context 'with invalid email format' do
      before do
        CSV.open(csv_path, 'w') do |csv|
          csv << ['Employee_Name', 'Employee_EmailID']
          csv << ['John Doe', 'invalid-email']
          csv << ['Jane Smith', 'jane.smith@example.com']
        end
      end

      it 'returns error for invalid email' do
        errors = CsvProcessorService.validate_employee_csv(csv_path)
        expect(errors).to include('Line 2: Invalid email format for invalid-email')
      end
    end

    context 'with multiple errors' do
      before do
        CSV.open(csv_path, 'w') do |csv|
          csv << ['Employee_Name', 'Employee_EmailID']
          csv << ['', '']
          csv << ['Jane Smith', 'invalid-email']
        end
      end

      it 'returns all errors' do
        errors = CsvProcessorService.validate_employee_csv(csv_path)
        expect(errors).to include('Line 2: Employee_Name is required')
        expect(errors).to include('Line 2: Employee_EmailID is required')
        expect(errors).to include('Line 3: Invalid email format for invalid-email')
      end
    end

    context 'with invalid CSV file' do
      let(:invalid_csv) { File.join(temp_dir, 'invalid.csv') }

      before do
        File.write(invalid_csv, 'invalid,csv,data')
      end

      it 'returns error for invalid CSV' do
        errors = CsvProcessorService.validate_employee_csv(invalid_csv)
        expect(errors.first).to match(/Error reading CSV file/)
      end
    end
  end

  describe '.validate_previous_assignments_csv' do
    let(:csv_path) { File.join(temp_dir, 'previous.csv') }

    context 'with valid CSV' do
      before do
        CSV.open(csv_path, 'w') do |csv|
          csv << ['Employee_Name', 'Employee_EmailID', 'Secret_Child_Name', 'Secret_Child_EmailID']
          csv << ['John Doe', 'john.doe@example.com', 'Jane Smith', 'jane.smith@example.com']
          csv << ['Jane Smith', 'jane.smith@example.com', 'Bob Johnson', 'bob.johnson@example.com']
        end
      end

      it 'returns empty array for valid CSV' do
        errors = CsvProcessorService.validate_previous_assignments_csv(csv_path)
        expect(errors).to be_empty
      end
    end

    context 'with missing required fields' do
      before do
        CSV.open(csv_path, 'w') do |csv|
          csv << ['Employee_Name', 'Employee_EmailID', 'Secret_Child_Name', 'Secret_Child_EmailID']
          csv << ['John Doe', '', 'Jane Smith', 'jane.smith@example.com']
          csv << ['Jane Smith', 'jane.smith@example.com', '', 'bob.johnson@example.com']
        end
      end

      it 'returns errors for missing fields' do
        errors = CsvProcessorService.validate_previous_assignments_csv(csv_path)
        expect(errors).to include('Line 2: Employee_EmailID is required')
        expect(errors).to include('Line 3: Secret_Child_Name is required')
      end
    end

    context 'with invalid email formats' do
      before do
        CSV.open(csv_path, 'w') do |csv|
          csv << ['Employee_Name', 'Employee_EmailID', 'Secret_Child_Name', 'Secret_Child_EmailID']
          csv << ['John Doe', 'invalid-email', 'Jane Smith', 'jane.smith@example.com']
          csv << ['Jane Smith', 'jane.smith@example.com', 'Bob Johnson', 'invalid-email-2']
        end
      end

      it 'returns errors for invalid emails' do
        errors = CsvProcessorService.validate_previous_assignments_csv(csv_path)
        expect(errors).to include('Line 2: Invalid email format for invalid-email')
        expect(errors).to include('Line 3: Invalid email format for invalid-email-2')
      end
    end
  end

  describe '.generate_sample_employee_csv' do
    it 'generates CSV with correct headers' do
      csv_data = CsvProcessorService.generate_sample_employee_csv
      expect(csv_data).to include('Employee_Name,Employee_EmailID')
    end

    it 'includes sample data' do
      csv_data = CsvProcessorService.generate_sample_employee_csv
      expect(csv_data).to include('John Doe,john.doe@acme.com')
      expect(csv_data).to include('Jane Smith,jane.smith@acme.com')
      expect(csv_data).to include('Bob Johnson,bob.johnson@acme.com')
    end

    it 'generates valid CSV format' do
      csv_data = CsvProcessorService.generate_sample_employee_csv
      lines = csv_data.lines.map(&:strip)
      expect(lines.count).to eq(4) # 1 header + 3 data rows
      expect(lines.first).to eq('Employee_Name,Employee_EmailID')
    end
  end

  describe '.generate_sample_previous_assignments_csv' do
    it 'generates CSV with correct headers' do
      csv_data = CsvProcessorService.generate_sample_previous_assignments_csv
      expect(csv_data).to include('Employee_Name,Employee_EmailID,Secret_Child_Name,Secret_Child_EmailID')
    end

    it 'includes sample data' do
      csv_data = CsvProcessorService.generate_sample_previous_assignments_csv
      expect(csv_data).to include('John Doe,john.doe@acme.com,Jane Smith,jane.smith@acme.com')
      expect(csv_data).to include('Jane Smith,jane.smith@acme.com,Bob Johnson,bob.johnson@acme.com')
      expect(csv_data).to include('Bob Johnson,bob.johnson@acme.com,John Doe,john.doe@acme.com')
    end

    it 'generates valid CSV format' do
      csv_data = CsvProcessorService.generate_sample_previous_assignments_csv
      lines = csv_data.lines.map(&:strip)
      expect(lines.count).to eq(4) # 1 header + 3 data rows
      expect(lines.first).to eq('Employee_Name,Employee_EmailID,Secret_Child_Name,Secret_Child_EmailID')
    end
  end

  describe 'private methods' do
    describe '.valid_email?' do
      it 'returns true for valid emails' do
        valid_emails = [
          'user@example.com',
          'user.name@example.com',
          'user+tag@example.com',
          'user123@domain.co.uk',
          'user@subdomain.example.org'
        ]
        
        valid_emails.each do |email|
          expect(CsvProcessorService.send(:valid_email?, email)).to be true
        end
      end

      it 'returns false for invalid emails' do
        invalid_emails = [
          'invalid-email',
          'user@',
          '@example.com',
          'user.example.com',
          'user space@example.com'
        ]
        
        invalid_emails.each do |email|
          expect(CsvProcessorService.send(:valid_email?, email)).to be false
        end
      end
    end
  end
end
