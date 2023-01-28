FactoryBot.define do
  factory :quiz do
    user
    title { Faker::Lorem.sentence }

    transient do
      questions_count { 0 }
      games_count { 0 }
    end

    trait :with_games do
      games_count { rand(2..4) }
    end

    trait :with_questions do
      questions_count { rand(2..4) }
    end

    after(:build) do |quiz, options|
      options.games_count.times do
        quiz.games << FactoryBot.build(:game, quiz: quiz)
      end

      options.questions_count.times do
        quiz.questions << FactoryBot.build(:question, :with_responses, quiz: quiz)
      end
    end
  end
end
