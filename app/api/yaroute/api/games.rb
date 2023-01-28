module Yaroute
  class API
    class Games < Grape::API
      helpers Grape::Pagy::Helpers

      resource :games do
        desc 'Return a Game'
        get ':id' do
          game = Game.find(params[:id])
          forbidden! unless current_user.can?(:read_game, game)

          present game, with: Yaroute::API::Entities::Game, type: :with_players
        end

        desc 'Return a Game playing informations'
        get ':id/play' do
          game = Game.find(params[:id])
          forbidden! unless current_user.can?(:play_game, game)

          not_allowed! unless game.started?

          present game, with: Yaroute::API::Entities::GameStarted, with_score: true
        end
      end
    end
  end
end
