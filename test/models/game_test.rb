require 'test_helper'

class GameTest < ActiveSupport::TestCase
  def setup
    @quiz = FactoryBot.create(:quiz)
    @quiz.questions.create(title: 'question1', points: 3).responses = [
      Response.create(title: 'ResponseA', value: true),
      Response.create(title: 'ResponseB', value: false)
    ]
    @quiz.questions.create(title: 'question2', points: 2).responses = [
      Response.create(title: 'ResponseA', value: true),
      Response.create(title: 'ResponseB', value: false)
    ]
    @quiz.questions.create(title: 'question3').responses = [
      Response.create(title: 'ResponseA', value: true),
      Response.create(title: 'ResponseB', value: false)
    ]

    @game = @quiz.games.create(code: '0000')

    @player1 = @game.players.create(name: 'player1')
    @player1.answers.create(
      [
        { response: @game.questions[0].responses.first },
        { response: @game.questions[1].responses.first },
        { response: @game.questions[2].responses.last }
      ]
    )

    @player2 = @game.players.create(name: 'player2')
    @player2.answers.create(
      [
        { response: @game.questions[0].responses.last },
        { response: @game.questions[1].responses.last },
        { response: @game.questions[2].responses.first }
      ]
    )

    @player3 = @game.players.create(name: 'player3')
    @player3.answers.create(
      [
        { response: @game.questions[0].responses.last },
        { response: @game.questions[1].responses.first },
        { response: @game.questions[2].responses.last }
      ]
    )
  end

  def test_players_answers
    answers = @game.questions[0].answers

    assert_equal [@player1.id], answers.good.pluck(:player_id).sort
    assert_equal [@player2.id, @player3.id], answers.bad.pluck(:player_id).sort

    assert answers.good.all?(&:good?)
    assert answers.bad.all?(&:bad?)
  end

  def test_players_scores
    assert_equal %w[player1 player3 player2], @game.players.sort_by_highest_score.map(&:name)

    assert_equal 3 + 2, @game.players.find_by(name: 'player1').score
    assert_equal 2, @game.players.find_by(name: 'player3').score
    assert_equal 1, @game.players.find_by(name: 'player2').score
  end
end
