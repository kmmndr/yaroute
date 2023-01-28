module Yaroute
  class API
    module Entities
      class Quiz < Grape::Entity
        expose :id

        expose :title

        expose :created_at
        expose :updated_at

        expose :questions, with: Yaroute::API::Entities::Question, if: { type: :with_questions }
        expose :games, with: Yaroute::API::Entities::Game, if: { type: :with_games }
      end
    end
  end
end
