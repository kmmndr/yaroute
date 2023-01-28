module Yaroute
  class API
    module Base
      extend ActiveSupport::Concern

      included do
        helpers Yaroute::API::Helpers::Authorization

        version %w[v1], using: :path, vendor: 'yaroute'
        prefix :api

        before do
          authenticate!
        end

        rescue_from ActiveRecord::RecordNotFound do
          rack_response({ 'message' => '404 Not found' }.to_json, 404)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          msg = e&.record&.errors&.full_messages&.join(';') || '422 Unprocessable Entity'
          rack_response({ 'message' => msg }.to_json, 422)
        end
      end
    end
  end
end
