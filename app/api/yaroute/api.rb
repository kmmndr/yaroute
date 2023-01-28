module Yaroute
  class API < Grape::API
    include Yaroute::API::Base

    mount ::Yaroute::API::Games
    mount ::Yaroute::API::Quizzes
  end
end
