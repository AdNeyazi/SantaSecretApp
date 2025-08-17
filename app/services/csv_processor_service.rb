require 'csv'

class CsvProcessorService
  class << self
    def validate_employee_csv(file_path)
      errors = []
      
      begin
        # Try different encoding approaches
        csv_content = File.read(file_path)
        
        # Try to detect and fix encoding issues
        unless csv_content.valid_encoding?
          csv_content = csv_content.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
        end
        
        CSV.parse(csv_content, headers: true, liberal_parsing: true).each_with_index do |row, index|
          line_number = index + 2 # +2 because index starts at 0 and we want to account for header
          
          # Check required fields
          if row['Employee_Name'].blank?
            errors << "Line #{line_number}: Employee_Name is required"
          end
          
          if row['Employee_EmailID'].blank?
            errors << "Line #{line_number}: Employee_EmailID is required"
          elsif !valid_email?(row['Employee_EmailID'])
            errors << "Line #{line_number}: Invalid email format for #{row['Employee_EmailID']}"
          end
        end
      rescue => e
        errors << "Error reading CSV file: #{e.message}"
      end
      
      errors
    end
    
    def validate_previous_assignments_csv(file_path)
      errors = []
      
      begin
        # Try different encoding approaches
        csv_content = File.read(file_path)
        
        # Try to detect and fix encoding issues
        unless csv_content.valid_encoding?
          csv_content = csv_content.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
        end
        
        CSV.parse(csv_content, headers: true, liberal_parsing: true).each_with_index do |row, index|
          line_number = index + 2 # +2 because index starts at 0 and we want to account for header
          
          # Check required fields
          if row['Employee_Name'].blank?
            errors << "Line #{line_number}: Employee_Name is required"
          end
          
          if row['Employee_EmailID'].blank?
            errors << "Line #{line_number}: Employee_EmailID is required"
          elsif !valid_email?(row['Employee_EmailID'])
            errors << "Line #{line_number}: Invalid email format for #{row['Employee_EmailID']}"
          end
          
          if row['Secret_Child_Name'].blank?
            errors << "Line #{line_number}: Secret_Child_Name is required"
          end
          
          if row['Secret_Child_EmailID'].blank?
            errors << "Line #{line_number}: Secret_Child_EmailID is required"
          elsif !valid_email?(row['Secret_Child_EmailID'])
            errors << "Line #{line_number}: Invalid email format for #{row['Secret_Child_EmailID']}"
          end
        end
      rescue => e
        errors << "Error reading CSV file: #{e.message}"
      end
      
      errors
    end
    
    def generate_sample_employee_csv
      CSV.generate(headers: true) do |csv|
        csv << ['Employee_Name', 'Employee_EmailID']
        csv << ['John Doe', 'john.doe@acme.com']
        csv << ['Jane Smith', 'jane.smith@acme.com']
        csv << ['Bob Johnson', 'bob.johnson@acme.com']
      end
    end
    
    def generate_sample_previous_assignments_csv
      CSV.generate(headers: true) do |csv|
        csv << ['Employee_Name', 'Employee_EmailID', 'Secret_Child_Name', 'Secret_Child_EmailID']
        csv << ['John Doe', 'john.doe@acme.com', 'Jane Smith', 'jane.smith@acme.com']
        csv << ['Jane Smith', 'jane.smith@acme.com', 'Bob Johnson', 'bob.johnson@acme.com']
        csv << ['Bob Johnson', 'bob.johnson@acme.com', 'John Doe', 'john.doe@acme.com']
      end
    end
    
    private
    
    def valid_email?(email)
      !!(email =~ URI::MailTo::EMAIL_REGEXP)
    end
  end
end
