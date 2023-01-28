module Yaroute
  class API
    module Helpers
      module Authorization
        def authenticate!
          error!('401 Unauthorized', 401) unless authorize
        end

        def disable!
          error!('503 Service Unavailable', 503)
        end

        def current_user
          @current_user ||= authorize
        end

        def authorize
          case headers['Authorization']
          when /^Basic .*$/
            return basic_authorization
          when /^(?:Token|Bearer) ([a-z0-9]+)$/
            return token_authorization(::Regexp.last_match(1))
          end

          nil
        end

        def basic_authorization
          r = Rack::Auth::Basic::Request.new(env)
          login, password = r.credentials

          account = Account.find_by(login: login)
          return nil if account.blank?

          return account.user if account.password == password

          nil
        end

        def token_authorization(token)
          return nil if token.blank?

          # Token.find_by(value: token)&.enabled?
          nil
        end

        def permitted_params
          declared(params, include_missing: false)
        end

        # error helpers

        def forbidden!(reason = nil)
          message = ['403 Forbidden']
          message << " - #{reason}" if reason
          render_api_error!(message.join(' '), 403)
        end

        def bad_request!(attribute = nil)
          message = ['400 Bad Request']
          message << "#{attribute} required" if attribute
          render_api_error!(message.join(' '), 400)
        end

        def not_found!(resource = nil)
          message = ['404 Not Found']
          message << resource if resource
          render_api_error!(message.join(' '), 404)
        end

        def unauthorized!
          render_api_error!('401 Unauthorized', 401)
        end

        def not_allowed!
          render_api_error!('405 Method Not Allowed', 405)
        end

        def conflict!(message = nil)
          render_api_error!(message || '409 Conflict', 409)
        end

        def file_to_large!
          render_api_error!('413 Request Entity Too Large', 413)
        end

        def not_implemented!
          render_api_error!('501 Not Implemented', 501)
        end

        def unprocessable_entity!(attribute = nil)
          message = ['422 Unprocessable Entity']
          message << attribute if attribute
          render_api_error!(message.join(' '), 422)
        end

        def render_validation_error!(model)
          return unless model.errors.any?

          bad_request!(model.errors.messages)
        end

        def render_api_error!(message, status)
          error!({ 'message' => message }, status)
        end
      end
    end
  end
end
