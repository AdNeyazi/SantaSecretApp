class Employee < ApplicationRecord
  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :slug, presence: true, uniqueness: true
  
  # Callbacks
  before_validation :generate_slug, on: :create
  
  # Associations
  has_many :secret_santa_assignments, class_name: 'SecretSantaAssignment', foreign_key: 'employee_id'
  has_many :assigned_as_secret_child, class_name: 'SecretSantaAssignment', foreign_key: 'secret_child_id'
  
  # Class methods
  def self.find_by_slug(slug)
    find_by(slug: slug)
  end
  
  # Instance methods
  def to_param
    slug
  end
  
  def secret_child_for_year(year)
    secret_santa_assignments.find_by(year: year)&.secret_child
  end
  
  def assigned_as_secret_child_for_year(year)
    assigned_as_secret_child.find_by(year: year)&.employee
  end
  
  private
  
  def generate_slug
    base_slug = name.parameterize
    counter = 0
    temp_slug = base_slug
    
    while Employee.exists?(slug: temp_slug)
      counter += 1
      temp_slug = "#{base_slug}-#{counter}"
    end
    
    self.slug = temp_slug
  end
end
