require 'test_helper'
require_relative 'shared/authorization_methods'

class Yaroute::API::QuizzesTest < MiniTest::Test
  include Rack::Test::Methods
  include AuthorizationMethods

  def app
    Yaroute::API
  end

  def setup
    @organizer_user = Account.create(login: 'organizer_user', password: 'secret').user
    @other_user = Account.create(login: 'other_user', password: 'secret').user
  end

  def test_get_api_quizzes_returns_an_empty_array_of_quizzes
    get '/api/v1/quizzes.json'
    assert_equal 401, last_response.status

    add_authorization_header(login: 'organizer_user', password: 'secret')

    get '/api/v1/quizzes.json'
    assert last_response.ok?
    assert_equal [], JSON.parse(last_response.body)

    FactoryBot.create(:quiz, title: 'foo', user: @organizer_user)

    get '/api/v1/quizzes.json'
    assert last_response.ok?
    parsed_quizzes = JSON.parse(last_response.body)
    assert_equal 1, parsed_quizzes.count
    parsed_quiz = parsed_quizzes.first
    assert_equal 'foo', parsed_quiz['title']
    assert_nil parsed_quiz['questions']

    add_authorization_header(login: 'other_user', password: 'secret')

    get '/api/v1/quizzes.json'
    assert last_response.ok?
    assert_equal [], JSON.parse(last_response.body)
  end

  def test_get_api_quizzes_id_returns_a_quiz_by_id
    quiz = FactoryBot.create(:quiz, questions_count: 3, title: 'foo', user: @organizer_user)
    assert_equal 3, quiz.questions.count

    add_authorization_header(login: 'organizer_user', password: 'secret')

    get "/api/v1/quizzes/#{quiz.id}.json"
    parsed_quiz = JSON.parse(last_response.body)
    assert_equal quiz.title, parsed_quiz['title']
    assert_equal 3, parsed_quiz['questions'].count

    add_authorization_header(login: 'other_user', password: 'secret')

    get "/api/v1/quizzes/#{quiz.id}.json"
    assert_equal 403, last_response.status
  end

  def test_get_api_quiz_games_returns_games
    quiz = FactoryBot.create(:quiz, games_count: 2, title: 'foo', user: @organizer_user)
    quiz.games.create(user: quiz.user, code: '1234')

    add_authorization_header(login: 'organizer_user', password: 'secret')

    get "/api/v1/quizzes/#{quiz.id}/games.json"
    parsed_games = JSON.parse(last_response.body)
    assert_equal 3, parsed_games.count

    parsed_last_game = parsed_games.last
    assert_equal '1234', parsed_last_game['code']

    add_authorization_header(login: 'other_user', password: 'secret')

    get "/api/v1/quizzes/#{quiz.id}/games.json"
    assert_equal 403, last_response.status
  end
end
