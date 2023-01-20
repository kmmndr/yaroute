class AccountsRules
  def self.allowed(object, subject)
    rules = []
    return rules unless subject.is_a?(Account)

    if subject.user == object
      rules << :read_account
      rules << :update_account
      rules << :delete_account
    end

    rules
  end
end
