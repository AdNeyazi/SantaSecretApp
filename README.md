# 🎅 Secret Santa App

A Rails application that automates the process of assigning Secret Santa gift exchanges among company employees. The app ensures fair and random assignments while avoiding repetitive pairings from previous years.

## ✨ Features

- **CSV Import/Export**: Upload employee lists and previous year assignments via CSV files
- **Smart Assignment Algorithm**: Generates Secret Santa assignments following business rules
- **Validation**: Comprehensive CSV validation with helpful error messages
- **Web Interface**: User-friendly dashboard for managing the entire process
- **Sample Files**: Download sample CSV templates for easy setup
- **Previous Year Avoidance**: Prevents duplicate assignments from previous years
- **Employee Profiles**: Individual employee pages with friendly URLs using slugs
- **Navigation**: Easy navigation between employee profiles and assignments

## 🚀 Quick Start

### Prerequisites

- Ruby 3.0 or higher
- Rails 7.2 or higher
- SQLite3 (default database)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/AdNeyazi/SantaSecretApp.git
   cd SantaSecretApp
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Set up the database**
   ```bash
   bundle exec rails db:create
   bundle exec rails db:migrate
   ```

4. **Start the server**
   ```bash
   bundle exec rails server
   ```

5. **Open your browser**
   Navigate to `http://localhost:3000`

## 📋 Usage

### 1. Upload Employee List

1. Go to the "Upload CSV" page
2. Download the sample employee CSV template
3. Fill in your employee information:
   ```
   Employee_Name,Employee_EmailID
   John Doe,john.doe@company.com
   Jane Smith,jane.smith@company.com
   ```
4. Upload the CSV file

### 2. Upload Previous Year Assignments (Optional)

1. If you have previous year's assignments, upload them to avoid duplicates
2. Use the sample previous assignments CSV template
3. Format:
   ```
   Employee_Name,Employee_EmailID,Secret_Child_Name,Secret_Child_EmailID
   John Doe,john.doe@company.com,Jane Smith,jane.smith@company.com
   ```

### 3. Generate Assignments

1. Click "Generate Assignments" on the dashboard
2. The system will create new Secret Santa assignments
3. View the assignments in the dashboard

### 4. Download Results

1. Click "Download Assignments" to get the CSV file
2. The file contains all current year assignments

## 🏗️ Architecture

### Models

- **Employee**: Stores employee information (name, email, slug) with automatic slug generation for friendly URLs
- **SecretSantaAssignment**: Manages assignments between employees and their secret children

### Services

- **SecretSantaService**: Core business logic for assignment generation
- **CsvProcessorService**: Handles CSV validation and processing

### Controllers

- **SecretSantaController**: Main controller handling all Secret Santa operations
- **EmployeesController**: Handles individual employee profile pages with slug-based routing

## 🔧 Business Rules

The Secret Santa assignment system follows these rules:

1. **No Self-Assignment**: An employee cannot be assigned to themselves
2. **Unique Assignment**: Each employee has exactly one secret child
3. **No Duplicates**: Each secret child is assigned to only one employee
4. **Previous Year Avoidance**: Avoids assignments that existed in the previous year
5. **Random Selection**: Uses a randomized algorithm for fair distribution

## 🧪 Testing

Run the test suite:

```bash
bin/rails test
```

The application includes comprehensive tests for:
- Model validations and associations
- Service business logic
- Controller actions
- CSV processing and validation
- Slug functionality for employee URLs

## 📁 File Structure

```
app/
├── controllers/
│   └── secret_santa_controller.rb
├── models/
│   ├── employee.rb
│   └── secret_santa_assignment.rb
├── services/
│   ├── secret_santa_service.rb
│   └── csv_processor_service.rb
└── views/
    └── secret_santa/
        ├── index.html.erb
        └── upload_csv.html.erb

test/
├── models/
├── services/
├── controllers/
└── fixtures/
```

## 🔒 CSV Format Requirements

### Employee CSV
- **Headers**: `Employee_Name`, `Employee_EmailID`
- **Employee_Name**: Full name of the employee (required)
- **Employee_EmailID**: Valid email address (required, unique)

### Previous Assignments CSV
- **Headers**: `Employee_Name`, `Employee_EmailID`, `Secret_Child_Name`, `Secret_Child_EmailID`
- All fields are required
- Email addresses must be valid and match existing employees

## 🚨 Error Handling

The application includes comprehensive error handling for:
- Invalid CSV formats
- Missing required fields
- Invalid email addresses
- Database constraint violations
- File upload issues

## 🎯 Future Enhancements

Potential improvements for future versions:
- Email notifications to employees
- Multiple year support
- Assignment preferences
- Gift budget tracking
- Team/department-based assignments
- REST API for integration

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For issues or questions:
1. Check the error messages in the application
2. Review the CSV format requirements
3. Ensure all required fields are present
4. Verify email addresses are valid

---

**Happy Secret Santa organizing! 🎁**
