FactoryBot.define do
  factory :employee do
    sequence(:name) { |n| "Employee #{n}" }
    sequence(:email) { |n| "employee#{n}@example.com" }
  end
end
