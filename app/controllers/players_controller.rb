class PlayersController < ApplicationController
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
    new_player = game.players.new(attrs)

    if new_player.save
      session[:player_id] = new_player.id

      redirect_to game_players_path(game),
                  notice: t('.notice_created')
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
    player.game
  end

  def player_params
    params.require(:player).permit(:code, :name)
  end

  def player
    @player ||= Player.find(session[:player_id])
  end
end
