module Authentication
  def connect(login:, password:)
    post login_url(login: login, password: password)
  end

  def disconnect
    delete logout_url
  end
end
