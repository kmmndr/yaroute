FactoryBot.define do
  factory :game do
    quiz
    code { rand(100000..999999) }
  end
end
