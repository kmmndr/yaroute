module Yaroute
  class API
    module Entities
      class Game < Grape::Entity
        expose :id

        expose :code

        expose :started_at
        expose :current_question_id
        expose :waiting_delay

        expose :finished_at

        expose :quiz_id
        expose :user_id

        expose :created_at
        expose :updated_at
      end
    end
  end
end
