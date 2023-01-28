module Yaroute
  class API
    module Entities
      class Response < Grape::Entity
        expose :id

        expose :title
        expose :value
      end
    end
  end
end
