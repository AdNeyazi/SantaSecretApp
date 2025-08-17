class SecretSantaAssignment < ApplicationRecord
  belongs_to :employee
  belongs_to :secret_child, class_name: 'Employee'
  
  # Validations
  validates :year, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :employee_id, presence: true
  validates :secret_child_id, presence: true
  validate :employee_cannot_be_own_secret_child
  validate :unique_assignment_per_year
  
  # Scopes
  scope :for_year, ->(year) { where(year: year) }
  
  private
  
  def employee_cannot_be_own_secret_child
    if employee_id == secret_child_id
      errors.add(:secret_child_id, "cannot be the same as employee")
    end
  end
  
  def unique_assignment_per_year
    existing_assignment = SecretSantaAssignment.where(
      year: year,
      employee_id: employee_id
    ).where.not(id: id || 0)
    
    if existing_assignment.exists?
      errors.add(:employee_id, "already has a secret child assignment for this year")
    end
  end
end
