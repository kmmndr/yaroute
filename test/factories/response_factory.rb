FactoryBot.define do
  factory :response do
    question
    title { Faker::Lorem.sentence }
    value { [true, false].sample }
  end
end
