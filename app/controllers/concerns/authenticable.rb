module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :set_user

    helper_method :current_user
    helper_method :authenticated?
  end

  attr_reader :current_user

  def set_user
    user_id = session[:user_id]
    return if user_id.nil?

    user = User.find_by(id: user_id)

    @current_user = user
  end

  def authenticated?
    !current_user.nil?
  end

  def authenticate!(user_id)
    session[:user_id] = user_id
  end

  def disconnect!
    session[:user_id] = nil

    reset_session
  end

  def authenticate
    if authenticated?
      session.delete(:redirect_after_login)

      true
    else
      reset_session

      session[:redirect_after_login] = request.fullpath
      redirect_to login_path

      false
    end
  end
end
