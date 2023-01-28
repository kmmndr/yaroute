module AuthorizationMethods
  def add_authorization_header(login:, password: nil)
    pass = Base64.strict_encode64("#{login}:#{password}")
    header 'Authorization', "Basic #{pass}"
  end
end
