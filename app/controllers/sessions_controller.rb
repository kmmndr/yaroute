class SessionsController < ApplicationController
  skip_before_action :authenticate

  def home
    redirect_to authenticated? ? quizzes_path : new_player_path
  end

  def new
    @account = Account.new
  end

  def create
    @account = account_by_login_password(params[:login], params[:password])

    if @account.present?
      connect_and_redirect!(@account.user)
    else
      flash.now.alert = 'Invalid login or password'
      render :new, status: :bad_request
    end
  end

  def destroy
    disconnect!
    flash.notice = 'You have been logged out'

    redirect_to login_path
  end

  private

  def connect_and_redirect!(user)
    authenticate!(user.id)
    Rails.logger.info "Logged in user: #{user.nil? ? 'nil' : user.id}"

    next_path = params[:redirect] || session[:redirect_after_login] || '/'

    redirect_to next_path
  end

  def account_by_login_password(login, password)
    return nil if login.blank? || password.blank?

    account = Account.find_by(login: login)
    return nil unless account.present? && account.password == password

    account
  end
end
