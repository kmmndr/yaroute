module Yaroute
  class API
    module Entities
      class Question < Grape::Entity
        expose :id

        expose :position
        expose :title

        expose :responses, with: Yaroute::API::Entities::Response
      end
    end
  end
end
