require 'test_helper'
require_relative 'shared/authorization_methods'

class Yaroute::API::GamesTest < MiniTest::Test
  include Rack::Test::Methods
  include AuthorizationMethods

  def app
    Yaroute::API
  end

  def setup
    @user1 = Account.create(login: 'user1', password: 'secret').user
    @user2 = Account.create(login: 'user2', password: 'secret').user
  end

  def test_get_api_games_id_returns_a_game_by_id
    quiz = FactoryBot.create(:quiz, title: 'foo', user: @user1)
    game = quiz.games.create(code: '1234')

    get "/api/v1/games/#{game.id}.json"
    assert_equal 401, last_response.status

    add_authorization_header(login: 'user2', password: 'secret')

    get "/api/v1/games/#{game.id}.json"
    assert_equal 403, last_response.status

    add_authorization_header(login: 'user1', password: 'secret')

    get "/api/v1/games/#{game.id}.json"
    parsed_game = JSON.parse(last_response.body)
    assert_equal '1234', parsed_game['code']
    assert_nil parsed_game['started_at']
    assert_equal [], parsed_game['players']

    game.players.create(
      [
        { name: 'player1' },
        { name: 'player2' }
      ]
    )
    player_user = game.players.first.user
    player_user.create_account(login: 'player1', password: 'secret')

    add_authorization_header(login: 'player1', password: 'secret')

    get "/api/v1/games/#{game.id}.json"
    parsed_game = JSON.parse(last_response.body)
    assert_nil parsed_game['started_at']
    assert_equal 2, parsed_game['players'].count

    get "/api/v1/games/#{game.id}/play.json"
    assert_equal 405, last_response.status

    game.start!
    get "/api/v1/games/#{game.id}/play.json"
    assert last_response.ok?
  end
end
