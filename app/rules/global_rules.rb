class GlobalRules
  def self.allowed(_object, subject)
    rules = []

    # GlobalRules are not related to any kind of subject
    return rules unless subject.nil?

    rules << :read_homepage

    rules
  end
end
