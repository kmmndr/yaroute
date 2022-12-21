# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

admin = Account.where(login: 'admin').first_or_create

if Rails.env.development?
  admin.update(password: 'admin')

  quiz = Quiz.where(title: 'Test').first_or_create

  quiz.questions.create(title: 'question1').responses = [
    Response.create(title: 'ResponseA', value: true),
    Response.create(title: 'ResponseB', value: false),
    Response.create(title: 'ResponseC', value: false),
    Response.create(title: 'ResponseD', value: false)
  ]

  quiz.questions.create(title: 'question2').responses = [
    Response.create(title: 'ResponseA', value: true),
    Response.create(title: 'ResponseB', value: false),
    Response.create(title: 'ResponseC', value: false),
    Response.create(title: 'ResponseD', value: false)
  ]

  quiz.questions.create(title: 'question3', points: 5).responses = [
    Response.create(title: 'ResponseA', value: true),
    Response.create(title: 'ResponseB', value: false),
    Response.create(title: 'ResponseC', value: false),
    Response.create(title: 'ResponseD', value: false)
  ]

  game = Game.create(quiz: quiz, code: '123')

  player1 = Player.create(game: game, name: 'player1')
  player1.answers.create(
    [
      { response: quiz.questions[0].responses.first },
      { response: quiz.questions[1].responses.first },
      { response: quiz.questions[2].responses.last }
    ]
  )

  player2 = Player.create(game: game, name: 'player2')
  player2.answers.create(
    [
      { response: quiz.questions[0].responses.last },
      { response: quiz.questions[1].responses.last },
      { response: quiz.questions[2].responses.first }
    ]
  )
end
