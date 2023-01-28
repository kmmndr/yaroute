module Yaroute
  class API
    module Entities
      class Player < Grape::Entity
        expose :id

        expose :name

        expose :game_id
        expose :user_id

        expose :score, if: { with_score: true }

        expose :created_at
        expose :updated_at
      end
    end
  end
end
