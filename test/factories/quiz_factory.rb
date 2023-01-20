FactoryBot.define do
  factory :quiz do
    user
    title { Faker::Lorem.sentence }
  end
end
