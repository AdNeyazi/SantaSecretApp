class CreateSecretSantaAssignments < ActiveRecord::Migration[7.2]
  def change
    create_table :secret_santa_assignments do |t|
      t.references :employee, null: false, foreign_key: { to_table: :employees }
      t.references :secret_child, null: false, foreign_key: { to_table: :employees }
      t.integer :year

      t.timestamps
    end
  end
end
