class PlayersController < DefaultController
  skip_before_action :authenticate, only: [:new, :create]

  def index
    @players = game.players.all
  end

  def show; end

  def new
    @player = Player.new
  end

  def edit; end

  def create
    attrs = player_params
    code = attrs.delete(:code)
    redirect_to new_player_path and return if code.blank?

    game = Game.find_by(code: code)
    redirect_to new_player_path(attrs) and return if game.blank?

    new_player = game.players.new(attrs)

    if new_player.save
      authenticate!(new_player.user.id)

      redirect_to game_play_path(game)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if player.update(player_params)
      redirect_to players_path,
                  notice: t('.notice_updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    player.destroy

    redirect_to player_path,
                notice: t('.notice_deleted')
  end

  private

  def game
    @game ||= Game.find(params[:game_id])
  end

  def player_params
    params.require(:player).permit(:code, :name)
  end

  def player
    @player ||= game.players.find_by(user_id: current_user.id) if game.present?
  end
end
