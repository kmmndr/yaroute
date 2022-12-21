class GamesController < DefaultController
  def show
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
        game.next_question!
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
    if game.started? && game.waiting_delay > 0
      auto_refresh!(game.waiting_delay + 1)
    else
      auto_refresh!(2)
    end
  end

  private

  def game
    @game ||= Game.find(params[:game_id] || params[:id])
  end

  def quiz
    Quiz.find(params[:quiz_id])
  end
end
