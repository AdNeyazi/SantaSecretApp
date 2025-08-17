require 'rails_helper'

RSpec.describe Employee, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      employee = build(:employee, name: 'John Doe', email: 'john.doe@example.com')
      expect(employee).to be_valid
    end

    it 'is invalid without a name' do
      employee = build(:employee, name: nil, email: 'john.doe@example.com')
      expect(employee).not_to be_valid
      expect(employee.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without an email' do
      employee = build(:employee, name: 'John Doe', email: nil)
      expect(employee).not_to be_valid
      expect(employee.errors[:email]).to include("can't be blank")
    end

    it 'is invalid with a duplicate email' do
      create(:employee, email: 'john.doe@example.com')
      employee = build(:employee, name: 'Jane Doe', email: 'john.doe@example.com')
      expect(employee).not_to be_valid
      expect(employee.errors[:email]).to include('has already been taken')
    end

    it 'is invalid with an invalid email format' do
      employee = build(:employee, name: 'John Doe', email: 'invalid-email')
      expect(employee).not_to be_valid
      expect(employee.errors[:email]).to include('is invalid')
    end

    it 'is valid with a valid email format' do
      valid_emails = ['john.doe@example.com', 'jane.smith+tag@company.co.uk', 'user123@domain.org']
      valid_emails.each do |email|
        employee = build(:employee, name: 'John Doe', email: email)
        expect(employee).to be_valid
      end
    end
  end

  describe 'associations' do
    let(:employee) { create(:employee) }
    let(:secret_child) { create(:employee) }

    it 'has many secret santa assignments' do
      assignment = create(:secret_santa_assignment, employee: employee, secret_child: secret_child)
      expect(employee.secret_santa_assignments).to include(assignment)
    end

    it 'has many assigned as secret child' do
      assignment = create(:secret_santa_assignment, employee: secret_child, secret_child: employee)
      expect(employee.assigned_as_secret_child).to include(assignment)
    end
  end

  describe 'instance methods' do
    let(:employee) { create(:employee) }
    let(:secret_child) { create(:employee) }
    let(:year) { Date.current.year }

    describe '#secret_child_for_year' do
      it 'returns the secret child for a specific year' do
        assignment = create(:secret_santa_assignment, 
                           employee: employee, 
                           secret_child: secret_child, 
                           year: year)
        expect(employee.secret_child_for_year(year)).to eq(secret_child)
      end

      it 'returns nil if no assignment exists for the year' do
        expect(employee.secret_child_for_year(year)).to be_nil
      end
    end

    describe '#assigned_as_secret_child_for_year' do
      it 'returns the employee who has this employee as secret child' do
        assignment = create(:secret_santa_assignment, 
                           employee: secret_child, 
                           secret_child: employee, 
                           year: year)
        expect(employee.assigned_as_secret_child_for_year(year)).to eq(secret_child)
      end

      it 'returns nil if not assigned as secret child for the year' do
        expect(employee.assigned_as_secret_child_for_year(year)).to be_nil
      end
    end
  end
end

  describe 'scopes' do
    let!(:active_employee) { create(:employee, active: true) }
    let!(:inactive_employee) { create(:employee, active: false) }

    describe '.active' do
      it 'returns only active employees' do
        expect(Employee.active).to include(active_employee)
        expect(Employee.active).not_to include(inactive_employee)
      end
    end
  end
end
