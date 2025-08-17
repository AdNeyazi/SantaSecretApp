class AddSlugsToExistingEmployees < ActiveRecord::Migration[7.2]
  def up
    Employee.find_each do |employee|
      next if employee.slug.present?
      
      base_slug = employee.name.parameterize
      counter = 0
      temp_slug = base_slug
      
      while Employee.where.not(id: employee.id).exists?(slug: temp_slug)
        counter += 1
        temp_slug = "#{base_slug}-#{counter}"
      end
      
      employee.update_column(:slug, temp_slug)
    end
  end

  def down
    # This migration cannot be safely reversed
    # as it would remove data
  end
end 