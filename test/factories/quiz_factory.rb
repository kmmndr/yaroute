FactoryBot.define do
  factory :quiz do
    user
    title { Faker::Lorem.sentence }

    transient do
      questions_count { 0 }
    end

    trait :with_questions do
      questions_count { rand(2..4) }
    end

    after(:build) do |quiz, options|
      options.questions_count.times do
        quiz.questions << FactoryBot.build(:question, :with_responses, quiz: quiz)
      end
    end
  end
end
