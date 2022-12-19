FactoryBot.define do
  factory :quiz do
    title { Faker::Lorem.sentence }
  end
end
