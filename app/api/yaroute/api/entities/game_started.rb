module Yaroute
  class API
    module Entities
      class GameStarted < Game
        expose :current_question, with: Yaroute::API::Entities::Question
        expose :waiting_delay

        expose :players, with: Yaroute::API::Entities::Player
      end
    end
  end
end
