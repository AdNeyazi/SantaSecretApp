require 'rails_helper'

RSpec.describe SecretSantaController, type: :controller do
  let(:employee) { create(:employee) }
  let(:secret_child) { create(:employee) }
  let(:current_year) { Date.current.year }

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns @employees' do
      get :index
      expect(assigns(:employees)).to eq(Employee.all)
    end

    it 'assigns @current_assignments' do
      get :index
      expect(assigns(:current_assignments)).to eq(SecretSantaAssignment.for_year(current_year).includes(:employee, :secret_child))
    end

    it 'assigns @previous_assignments' do
      get :index
      expect(assigns(:previous_assignments)).to eq(SecretSantaAssignment.for_year(current_year - 1).includes(:employee, :secret_child))
    end
  end

  describe 'POST #create_assignments' do
    let!(:employees) { create_list(:employee, 3) }

    context 'when successful' do
      it 'creates new assignments' do
        expect {
          post :create_assignments
        }.to change(SecretSantaAssignment, :count).by(3)
      end

      it 'sets success flash message' do
        post :create_assignments
        expect(flash[:success]).to eq('Secret Santa assignments created successfully!')
      end

      it 'redirects to index' do
        post :create_assignments
        expect(response).to redirect_to(secret_santa_index_path)
      end
    end

    context 'when error occurs' do
      before do
        allow_any_instance_of(SecretSantaService).to receive(:generate_assignments).and_raise('Test error')
      end

      it 'sets error flash message' do
        post :create_assignments
        expect(flash[:error]).to eq('Error creating assignments: Test error')
      end

      it 'redirects to index' do
        post :create_assignments
        expect(response).to redirect_to(secret_santa_index_path)
      end
    end
  end

  describe 'GET #upload_csv' do
    it 'returns http success' do
      get :upload_csv
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #upload_csv' do
    let(:temp_dir) { Dir.mktmpdir }
    let(:csv_path) { File.join(temp_dir, 'employees.csv') }
    
    after(:each) do
      FileUtils.remove_entry temp_dir
    end

    context 'with employee CSV' do
      before do
        CSV.open(csv_path, 'w') do |csv|
          csv << ['Employee_Name', 'Employee_EmailID']
          csv << ['John Doe', 'john.doe@example.com']
        end
      end

      it 'processes employee CSV successfully' do
        file = Rack::Test::UploadedFile.new(csv_path, 'text/csv')
        post :upload_csv, params: { employee_csv: file }
        
        expect(flash[:success]).to eq('Employee CSV uploaded and processed successfully!')
        expect(response).to redirect_to(secret_santa_index_path)
      end

      it 'creates employees from CSV' do
        file = Rack::Test::UploadedFile.new(csv_path, 'text/csv')
        expect {
          post :upload_csv, params: { employee_csv: file }
        }.to change(Employee, :count).by(1)
      end
    end

    context 'with previous assignments CSV' do
      let!(:employee1) { create(:employee, email: 'john.doe@example.com') }
      let!(:employee2) { create(:employee, email: 'jane.smith@example.com') }
      
      before do
        CSV.open(csv_path, 'w') do |csv|
          csv << ['Employee_Name', 'Employee_EmailID', 'Secret_Child_Name', 'Secret_Child_EmailID']
          csv << ['John Doe', 'john.doe@example.com', 'Jane Smith', 'jane.smith@example.com']
        end
      end

      it 'processes previous assignments CSV successfully' do
        file = Rack::Test::UploadedFile.new(csv_path, 'text/csv')
        post :upload_csv, params: { previous_assignments_csv: file }
        
        expect(flash[:success]).to eq('Previous assignments CSV uploaded and processed successfully!')
        expect(response).to redirect_to(secret_santa_index_path)
      end

      it 'creates previous assignments from CSV' do
        file = Rack::Test::UploadedFile.new(csv_path, 'text/csv')
        expect {
          post :upload_csv, params: { previous_assignments_csv: file }
        }.to change(SecretSantaAssignment, :count).by(1)
      end
    end

    context 'with no file' do
      it 'sets error flash message' do
        post :upload_csv
        expect(flash[:error]).to eq('Please select a CSV file to upload.')
        expect(response).to redirect_to(secret_santa_upload_csv_path)
      end
    end

    context 'with validation errors' do
      before do
        CSV.open(csv_path, 'w') do |csv|
          csv << ['Employee_Name', 'Employee_EmailID']
          csv << ['', 'invalid-email']
        end
      end

      it 'sets error flash message for validation errors' do
        file = Rack::Test::UploadedFile.new(csv_path, 'text/csv')
        post :upload_csv, params: { employee_csv: file }
        
        expect(flash[:error]).to include('CSV validation errors')
        expect(response).to redirect_to(secret_santa_upload_csv_path)
      end
    end
  end

  describe 'GET #download_csv' do
    let!(:assignment) do
      create(:secret_santa_assignment, 
             employee: employee, 
             secret_child: secret_child, 
             year: current_year)
    end

    context 'when successful' do
      it 'returns CSV data' do
        get :download_csv
        expect(response.content_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).to include("secret_santa_assignments_#{current_year}.csv")
      end

      it 'includes assignment data' do
        get :download_csv
        expect(response.body).to include(employee.name)
        expect(response.body).to include(employee.email)
        expect(response.body).to include(secret_child.name)
        expect(response.body).to include(secret_child.email)
      end
    end

    context 'when error occurs' do
      before do
        allow_any_instance_of(SecretSantaService).to receive(:export_assignments_to_csv).and_raise('Test error')
      end

      it 'sets error flash message' do
        get :download_csv
        expect(flash[:error]).to eq('Error generating CSV: Test error')
        expect(response).to redirect_to(secret_santa_index_path)
      end
    end
  end

  describe 'GET #download_sample_employee_csv' do
    it 'returns sample employee CSV' do
      get :download_sample_employee_csv
      expect(response.content_type).to eq('text/csv')
      expect(response.headers['Content-Disposition']).to include('sample_employees.csv')
      expect(response.body).to include('Employee_Name,Employee_EmailID')
    end
  end

  describe 'GET #download_sample_previous_assignments_csv' do
    it 'returns sample previous assignments CSV' do
      get :download_sample_previous_assignments_csv
      expect(response.content_type).to eq('text/csv')
      expect(response.headers['Content-Disposition']).to include('sample_previous_assignments.csv')
      expect(response.body).to include('Employee_Name,Employee_EmailID,Secret_Child_Name,Secret_Child_EmailID')
    end
  end

  describe 'private methods' do
    describe '#set_service' do
      it 'sets @service instance variable' do
        get :index
        expect(assigns(:service)).to be_a(SecretSantaService)
      end
    end
  end
end
