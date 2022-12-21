class AnswersController < DefaultController
  def create
    player.answers.create(answer_params)

    redirect_to game_play_path(player.game)
  end

  private

  def player
    @player ||= Player.find(params[:player_id])
  end

  def answer_params
    params.require(:answer).permit(:response_id)
  end
end
