require 'rails_helper'

RSpec.describe SecretSantaAssignment, type: :model do
  let(:employee) { create(:employee) }
  let(:secret_child) { create(:employee) }
  let(:year) { Date.current.year }

  describe 'validations' do
    it 'is valid with valid attributes' do
      assignment = build(:secret_santa_assignment, 
                         employee: employee, 
                         secret_child: secret_child, 
                         year: year)
      expect(assignment).to be_valid
    end

    it 'is invalid without a year' do
      assignment = build(:secret_santa_assignment, 
                         employee: employee, 
                         secret_child: secret_child, 
                         year: nil)
      expect(assignment).not_to be_valid
      expect(assignment.errors[:year]).to include("can't be blank")
    end

    it 'is invalid with a non-integer year' do
      assignment = build(:secret_santa_assignment, 
                         employee: employee, 
                         secret_child: secret_child, 
                         year: 2023.5)
      expect(assignment).not_to be_valid
      expect(assignment.errors[:year]).to include('must be an integer')
    end

    it 'is invalid with a year less than 1' do
      assignment = build(:secret_santa_assignment, 
                         employee: employee, 
                         secret_child: secret_child, 
                         year: 0)
      expect(assignment).not_to be_valid
      expect(assignment.errors[:year]).to include('must be greater than 0')
    end

    it 'is invalid without an employee' do
      assignment = build(:secret_santa_assignment, 
                         employee: nil, 
                         secret_child: secret_child, 
                         year: year)
      expect(assignment).not_to be_valid
      expect(assignment.errors[:employee_id]).to include("can't be blank")
    end

    it 'is invalid without a secret child' do
      assignment = build(:secret_santa_assignment, 
                         employee: employee, 
                         secret_child: nil, 
                         year: year)
      expect(assignment).not_to be_valid
      expect(assignment.errors[:secret_child_id]).to include("can't be blank")
    end
  end

  describe 'custom validations' do
    describe 'employee_cannot_be_own_secret_child' do
      it 'is invalid when employee is the same as secret child' do
        assignment = build(:secret_santa_assignment, 
                           employee: employee, 
                           secret_child: employee, 
                           year: year)
        expect(assignment).not_to be_valid
        expect(assignment.errors[:secret_child_id]).to include("cannot be the same as employee")
      end

      it 'is valid when employee is different from secret child' do
        assignment = build(:secret_santa_assignment, 
                           employee: employee, 
                           secret_child: secret_child, 
                           year: year)
        expect(assignment).to be_valid
      end
    end

    describe 'unique_assignment_per_year' do
      it 'is invalid when employee already has an assignment for the year' do
        create(:secret_santa_assignment, 
               employee: employee, 
               secret_child: secret_child, 
               year: year)
        
        another_secret_child = create(:employee)
        duplicate_assignment = build(:secret_santa_assignment, 
                                   employee: employee, 
                                   secret_child: another_secret_child, 
                                   year: year)
        
        expect(duplicate_assignment).not_to be_valid
        expect(duplicate_assignment.errors[:employee_id]).to include("already has a secret child assignment for this year")
      end

      it 'is valid when employee has no assignment for the year' do
        assignment = build(:secret_santa_assignment, 
                           employee: employee, 
                           secret_child: secret_child, 
                           year: year)
        expect(assignment).to be_valid
      end

      it 'is valid when updating existing assignment' do
        assignment = create(:secret_santa_assignment, 
                           employee: employee, 
                           secret_child: secret_child, 
                           year: year)
        
        # Update the same assignment
        assignment.secret_child = create(:employee)
        expect(assignment).to be_valid
      end
    end
  end

  describe 'associations' do
    it 'belongs to an employee' do
      assignment = create(:secret_santa_assignment, 
                         employee: employee, 
                         secret_child: secret_child, 
                         year: year)
      expect(assignment.employee).to eq(employee)
    end

    it 'belongs to a secret child' do
      assignment = create(:secret_santa_assignment, 
                         employee: employee, 
                         secret_child: secret_child, 
                         year: year)
      expect(assignment.secret_child).to eq(secret_child)
    end
  end

  describe 'scopes' do
    let!(:current_year_assignment) { create(:secret_santa_assignment, year: year) }
    let!(:previous_year_assignment) { create(:secret_santa_assignment, year: year - 1) }

    describe '.for_year' do
      it 'returns assignments for a specific year' do
        expect(SecretSantaAssignment.for_year(year)).to include(current_year_assignment)
        expect(SecretSantaAssignment.for_year(year)).not_to include(previous_year_assignment)
      end
    end
  end
end
