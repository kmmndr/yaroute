module Yaroute
  class API
    module Entities
      class Response < Grape::Entity
        expose :id

        expose :title
        expose :value, if: { type: :with_value }
      end
    end
  end
end
