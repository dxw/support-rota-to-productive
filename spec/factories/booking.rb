FactoryBot.define do
  factory :booking, class: Productive::Booking do
    id { rand(10000) }
    hours { 7 }
    time { 420 }
    started_on { Date.today }
    ended_on { Date.today }
    note { nil }
    total_time { time * total_working_days }
    total_working_days { 1 }
    percentage { nil }
    created_at { DateTime.now }
    updated_at { DateTime.now }
    people_custom_fields { nil }
    approved { false }
    approved_at { nil }
    rejected { false }
    rejected_reason { nil }
    rejected_at { nil }
    canceled { false }
    canceled_at { nil }
    person { build(:person) }

    skip_create
  end
end
