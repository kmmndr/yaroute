require 'test_helper'

class AnswerTest < ActiveSupport::TestCase
  def setup
    @quiz = FactoryBot.create(:quiz)
    @old_question = @quiz.questions.create(title: 'old_question')
    @old_question.responses = [
      Response.create(title: 'ResponseA', value: true)
    ]
    @current_question = @quiz.questions.create(title: 'current_question')
    @current_question.responses = [
      Response.create(title: 'ResponseA', value: true)
    ]
    @next_question = @quiz.questions.create(title: 'next_question')
    @next_question.responses = [
      Response.create(title: 'ResponseA', value: true)
    ]

    @game = @quiz.games.create(code: '0000', current_question: @current_question, current_question_at: Time.zone.now)

    @player1 = @game.players.create(name: 'player1')
    @player1.answers.create(
      [
        { response: @game.questions[0].responses.first },
        { response: @game.questions[1].responses.first },
        { response: @game.questions[2].responses.last }
      ]
    )
  end

  def test_answer_question_active?
    assert @player1.answers.new({ response: @current_question.responses.first }).question_active?
    assert_not @player1.answers.new({ response: @old_question.responses.first }).question_active?
    assert_not @player1.answers.new({ response: @next_question.responses.first }).question_active?

    @game.current_question_at = 1.hour.ago
    @game.save!
    assert_not @player1.answers.new({ response: @current_question.responses.first }).question_active?
  end
end
