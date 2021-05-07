FactoryBot.define do
  factory :support_rotation, class: SupportRotaToProductive::SupportRotation do
    date { "2021-03-01" }
    employee { build(:employee) }

    skip_create
  end
end
