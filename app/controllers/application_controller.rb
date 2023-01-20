class ApplicationController < ActionController::Base
  include Authenticable
  include Authorizable
  include AutoRefreshable

  before_action :authenticate

  rescue_from Yaroute::Exceptions::ForbiddenError, with: ->(_exception) { forbid }
end
