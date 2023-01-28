FactoryBot.define do
  factory :question do
    quiz
    title { Faker::Lorem.sentence }
    points { rand(1..10) }

    transient do
      responses_count { 0 }
    end

    trait :with_responses do
      responses_count { rand(3..4) }
    end

    after(:build) do |question, options|
      options.responses_count.times do
        question.responses << FactoryBot.build(:response, question: question)
      end
    end
  end
end
