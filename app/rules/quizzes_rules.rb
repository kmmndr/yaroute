class QuizzesRules
  def self.allowed(object, subject)
    rules = []
    return rules unless subject.nil? || subject.is_a?(Quiz)

    return rules if object.account.blank?

    rules << :read_quizzes
    rules << :create_quiz

    if subject.present? && subject.user == object
      rules << :read_quiz
      rules << :update_quiz
      rules << :delete_quiz
    end

    rules
  end
end
