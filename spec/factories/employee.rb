FactoryBot.define do
  factory :employee, class: SupportRotaToProductive::Employee do
    email { FFaker::Internet.email }

    transient do
      in_productive? { true }
    end

    skip_create

    trait :not_in_productive do
      transient do
        in_productive? { false }
      end
    end
  end
end
