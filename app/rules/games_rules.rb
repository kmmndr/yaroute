class GamesRules
  def self.allowed(object, subject)
    rules = []
    return rules unless subject.is_a?(Game)

    object_own_the_game = subject.user == object
    object_is_a_player = subject.players.ids.intersect?(object.players.ids)

    rules << :read_game if object_own_the_game || object_is_a_player
    rules << :play_game if object_is_a_player

    if object_own_the_game
      rules << :update_game
      rules << :delete_game
    end

    rules
  end
end
