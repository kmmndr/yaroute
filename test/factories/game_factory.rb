FactoryBot.define do
  factory :game do
    quiz
    code { rand(100000..999999) }

    after(:build) do |game, _options|
      game.user = game.quiz.user
    end
  end
end
