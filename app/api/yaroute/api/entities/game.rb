module Yaroute
  class API
    module Entities
      class Game < Grape::Entity
        expose :id

        expose :code

        expose :quiz_id
        expose :user_id

        expose :started_at
        expose :finished_at

        expose :created_at
        expose :updated_at

        expose :players, with: Yaroute::API::Entities::Player
      end
    end
  end
end
