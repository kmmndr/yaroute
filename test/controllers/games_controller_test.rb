require 'test_helper'
require_relative 'shared/authentication'

class GamesControllerTest < ActionDispatch::IntegrationTest
  include Authentication

  setup do
    @user1 = Account.create(login: 'user1', password: 'secret').user
    @user2 = Account.create(login: 'user2', password: 'secret').user

    quiz = @user1.quizzes.create(title: 'quiz')
    @game = quiz.games.create(code: '123')
  end

  test 'should read own games' do
    get game_url(@game)
    assert_redirected_to login_path

    connect(login: 'user1', password: 'secret')
    get game_url(@game)
    assert_response :success

    disconnect
    get game_url(@game)
    assert_redirected_to login_path

    connect(login: 'user2', password: 'secret')
    get game_url(@game)
    assert_redirected_to new_player_path
  end

  test 'should update own games' do
    get game_url(@game)
    assert_redirected_to login_path

    connect(login: 'user1', password: 'secret')
    put game_next_question_url(@game)
    assert_redirected_to game_play_path(@game)
    put game_reset_url(@game)
    assert_redirected_to game_path(@game)

    disconnect
    get game_url(@game)
    assert_redirected_to login_path

    connect(login: 'user2', password: 'secret')
    put game_next_question_url(@game)
    assert_response :forbidden
    put game_reset_url(@game)
    assert_response :forbidden
  end

  test 'should delete own games' do
    skip 'Not yet implemented'

    quiz = @user1.quizzes.create(title: 'quiz')
    @game2 = quiz.games.create

    get game_url(@game)
    assert_redirected_to new_player_path

    connect(login: 'user1', password: 'secret')
    delete game_url(@game)
    assert_redirected_to quizzes_path

    disconnect
    get game_url(@game2)
    assert_redirected_to new_player_path

    connect(login: 'user2', password: 'secret')
    delete game_url(@game2)
    assert_response :forbidden
  end

  test 'should play games' do
    @game.quiz.questions.create(title: 'question1').responses = [
      Response.create(title: 'ResponseA', value: true),
      Response.create(title: 'ResponseB', value: true)
    ]
    question = @game.quiz.questions.last

    post players_url, params: { player: { code: @game.code, name: 'foo' } }
    assert_redirected_to game_play_path(@game)

    player = @game.players.last
    assert_equal 'foo', player.name
    assert player.answers.none?

    # fake next_step as game organizer
    assert_not @game.current_question.present?
    @game.start!
    @game.next_step!
    assert @game.current_question.present?

    post player_answers_url(player), params: { answer: { response_id: question.responses.first.id } }
    assert_redirected_to game_play_path(@game)
    assert player.answers.count == 1
  end
end
