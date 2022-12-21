class ApplicationController < ActionController::Base
  include Authenticable

  before_action :authenticate
end
