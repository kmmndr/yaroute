FactoryBot.define do
  factory :question do
    quiz
    title { Faker::Lorem.sentence }
    points { rand(1..10) }
  end
end
