class GamesController < DefaultController
  def show
    redirect_to new_player_path and return if restrict_access?

    @game = game
  end

  def create
    new_game = quiz.games.new(user: current_user)

    if new_game.save
      redirect_to new_game,
                  notice: t('.notice_created')
    else
      redirect_to quiz
    end
  end

  def reset
    game.reset! if game.user == current_user

    redirect_to game_path(game)
  end

  def next_question
    if game.user == current_user
      if game.started?
        game.next_step! if game.waiting_delay == 0
      else
        game.reset!
        game.start!(at: 5.seconds.from_now)
      end

      redirect_to game_play_path(game)
    else
      redirect_to game_path(game)
    end
  end

  def play
    redirect_to new_player_path and return if restrict_access?

    @player = current_user.player_in_game(game)
    @answer = if (player = current_user.player_in_game(game))
                game.current_question&.answers&.where(player: player)&.first_or_initialize
              end

    if game.started? && game.waiting_delay > 0
      auto_refresh!(game.waiting_delay + 1)
    elsif !game.finished?
      auto_refresh!(4)
    else
      redirect_to game_path(game)
    end
  end

  private

  def restrict_access?
    return false if current_user == game.user
    return false if game.players.ids.intersect?(current_user.players.ids)

    true
  end

  def game
    @game ||= Game.find(params[:game_id] || params[:id])
  end

  def quiz
    Quiz.find(params[:quiz_id])
  end
end
