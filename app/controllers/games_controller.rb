class GamesController < DefaultController
  def show
    @game = game

    redirect_to new_player_path unless current_user.can?(:read_game, @game)
  end

  def create
    forbid! unless current_user.can?(:create_quizzes_game, quiz)

    new_game = quiz.games.new(user: current_user)

    if new_game.save
      redirect_to new_game,
                  notice: t('.notice_created')
    else
      redirect_to quiz
    end
  end

  def reset
    forbid! unless current_user.can?(:update_game, game)

    game.reset! if game.user == current_user

    redirect_to game_path(game)
  end

  def next_question
    forbid! unless current_user.can?(:update_game, game)

    if game.user == current_user
      if game.started?
        game.next_step! if game.remaining_time == 0
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
    redirect_to new_player_path and return unless current_user.can?(:read_game, game)

    @player = current_user.player_in_game(game)
    @answer = if (player = current_user.player_in_game(game))
                game.current_question&.answers&.where(player: player)&.first_or_initialize
              end

    if game.started? && game.remaining_time > 0
      auto_refresh!(game.remaining_time + 1)
    elsif !game.finished?
      auto_refresh!(4)
    else
      redirect_to game_path(game)
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
