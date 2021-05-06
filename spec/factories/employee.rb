FactoryBot.define do
  factory :employee, class: SupportRotaToProductive::Employee do
    email { FFaker::Internet.email }

    transient do
      in_productive? { true }
    end

    skip_create

    after(:create) do |employee, evaluator|
      create(:person, email: employee.email) if evaluator.in_productive?
    end

    trait :not_in_productive do
      transient do
        in_productive? { false }
      end
    end
  end
end
