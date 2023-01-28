require 'test_helper'

class Yaroute::API::QuizzesTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Yaroute::API
  end

  def setup
    @user1 = Account.create(login: 'user1', password: 'secret').user

    pass = Base64.strict_encode64('user1:secret')
    header 'Authorization', "Basic #{pass}"
  end

  def test_get_api_quizzes_returns_an_empty_array_of_quizzes
    get '/api/v1/quizzes.json'
    assert last_response.ok?
    assert_equal [], JSON.parse(last_response.body)

    FactoryBot.create(:quiz, title: 'foo', user: @user1)

    get '/api/v1/quizzes.json'
    assert last_response.ok?
    parsed_quizzes = JSON.parse(last_response.body)
    assert_equal 1, parsed_quizzes.count
    parsed_quiz = parsed_quizzes.first
    assert_equal 'foo', parsed_quiz['title']
    assert_nil parsed_quiz['questions']
  end

  def test_get_api_quizzes_id_returns_a_quiz_by_id
    quiz = FactoryBot.create(:quiz, questions_count: 3, title: 'foo', user: @user1)
    assert_equal 3, quiz.questions.count

    get "/api/v1/quizzes/#{quiz.id}.json"
    parsed_quiz = JSON.parse(last_response.body)
    assert_equal quiz.title, parsed_quiz['title']
    assert_equal 3, parsed_quiz['questions'].count
  end

  def test_get_api_quiz_games_returns_games
    quiz = FactoryBot.create(:quiz, games_count: 2, title: 'foo', user: @user1)
    quiz.games.create(user: quiz.user, code: '1234')

    get "/api/v1/quizzes/#{quiz.id}/games.json"
    parsed_games = JSON.parse(last_response.body)
    assert_equal 3, parsed_games.count

    parsed_last_game = parsed_games.last
    assert_equal '1234', parsed_last_game['code']
  end
end
