class AccountsController < DefaultController
  skip_before_action :authenticate, only: [:new, :create]

  def show
    forbid! unless current_user.can?(:read_account, account)

    @account = account
  end

  def new
    attrs = {}
    attrs[:login] = current_user.first_name&.downcase if authenticated?
    @account = Account.new(attrs)
  end

  def edit
    forbid! unless current_user.can?(:update_account, account)

    @account = account
  end

  def create
    @account = if authenticated?
                 current_user.build_account
               else
                 Account.new
               end

    if @account.update(account_params)
      authenticate!(@account.user.id)

      redirect_path = if (game = @account.user.players.last&.game)
                        game_play_path(game)
                      else
                        @account
                      end

      redirect_to redirect_path,
                  notice: t('.notice_created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    forbid! unless current_user.can?(:update_account, account)

    @account = account

    if @account.update(account_params)
      redirect_to edit_account_path(@account),
                  notice: t('.notice_updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    forbid! unless current_user.can?(:delete_account, account)

    account.destroy

    redirect_to root_path,
                notice: t('.notice_deleted')
  end

  private

  def account
    @account ||= Account.find(params[:account_id] || params[:id])
  end

  def account_params
    params.require(:account).permit(:login, :password)
  end
end
