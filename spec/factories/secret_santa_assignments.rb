FactoryBot.define do
  factory :secret_santa_assignment do
    association :employee, factory: :employee
    association :secret_child, factory: :employee
    year { Date.current.year }
  end
end
