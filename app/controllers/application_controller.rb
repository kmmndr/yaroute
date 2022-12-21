class ApplicationController < ActionController::Base
  include Authenticable
  include AutoRefreshable

  before_action :authenticate
end
