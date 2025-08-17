class SecretSantaController < ApplicationController
  require_relative '../services/secret_santa_service'
  require_relative '../services/csv_processor_service'
  
  before_action :set_service
  
  def index
    @employees = Employee.all
    @current_assignments = SecretSantaAssignment.for_year(Date.current.year).includes(:employee, :secret_child)
    @previous_assignments = SecretSantaAssignment.for_year(Date.current.year - 1).includes(:employee, :secret_child)
  end

  def create_assignments
    if request.get?
      flash[:info] = "Please use the 'Generate Assignments' button on the dashboard to create new Secret Santa assignments."
      redirect_to secret_santa_index_path
      return
    end
    
    begin
      @assignments = @service.generate_assignments
      flash[:success] = "Secret Santa assignments created successfully!"
      redirect_to secret_santa_index_path
    rescue => e
      flash[:error] = "Error creating assignments: #{e.message}"
      redirect_to secret_santa_index_path
    end
  end

  def upload_csv
    if request.post?
      if params[:employee_csv].present?
        handle_employee_csv_upload
      elsif params[:previous_assignments_csv].present?
        handle_previous_assignments_csv_upload
      else
        flash[:error] = "Please select a CSV file to upload."
        redirect_to secret_santa_upload_csv_path
        return
      end
    end
  end

  def download_csv
    begin
      csv_data = @service.export_assignments_to_csv
      send_data csv_data, 
                filename: "secret_santa_assignments_#{Date.current.year}.csv",
                type: 'text/csv'
    rescue => e
      flash[:error] = "Error generating CSV: #{e.message}"
      redirect_to secret_santa_index_path
    end
  end
  
  def download_sample_employee_csv
    csv_data = CsvProcessorService.generate_sample_employee_csv
    send_data csv_data, 
              filename: "sample_employees.csv",
              type: 'text/csv'
  end
  
  def download_sample_previous_assignments_csv
    csv_data = CsvProcessorService.generate_sample_previous_assignments_csv
    send_data csv_data, 
              filename: "sample_previous_assignments.csv",
              type: 'text/csv'
  end

  private

  def set_service
    @service = SecretSantaService.new
  end

  def handle_employee_csv_upload
    uploaded_file = params[:employee_csv]
    
    # Validate file
    errors = CsvProcessorService.validate_employee_csv(uploaded_file.path)
    
    if errors.any?
      flash[:error] = "CSV validation errors: #{errors.join(', ')}"
      redirect_to secret_santa_upload_csv_path
      return
    end
    
    begin
      @service.process_employee_csv(uploaded_file.path)
      flash[:success] = "Employee CSV uploaded and processed successfully!"
      redirect_to secret_santa_index_path
    rescue => e
      flash[:error] = "Error processing employee CSV: #{e.message}"
      redirect_to secret_santa_upload_csv_path
    end
  end

  def handle_previous_assignments_csv_upload
    uploaded_file = params[:previous_assignments_csv]
    
    # Validate file
    errors = CsvProcessorService.validate_previous_assignments_csv(uploaded_file.path)
    
    if errors.any?
      flash[:error] = "CSV validation errors: #{errors.join(', ')}"
      redirect_to secret_santa_upload_csv_path
      return
    end
    
    begin
      @service.process_previous_assignments_csv(uploaded_file.path)
      flash[:success] = "Previous assignments CSV uploaded and processed successfully!"
      redirect_to secret_santa_index_path
    rescue => e
      flash[:error] = "Error processing previous assignments CSV: #{e.message}"
      redirect_to secret_santa_upload_csv_path
    end
  end
end
