class AbilitiesHandler
  attr_accessor :abilities

  def initialize
    self.abilities = Six.new

    abilities.add(:global_rules, GlobalRules)

    abilities.add(:accounts_rules, AccountsRules)
    abilities.add(:games_rules, GamesRules)
    abilities.add(:quizzes_rules, QuizzesRules)
  end
end
