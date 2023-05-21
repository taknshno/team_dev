class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy]

  def index
    @teams = Team.all
  end

  def show
    @working_team = @team
    change_keep_team(current_user, @team)
  end

  def new
    @team = Team.new
  end

  def edit; end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to @team, notice: I18n.t('views.messages.create_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :new
    end
  end

  def update
    if current_user.id == @team.owner_id
      if @team.update(team_params)
        redirect_to @team, notice: I18n.t('views.messages.update_team')
      else
        flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
        render :edit
      end
    else
      redirect_to @team, notice: I18n.t('views.messages.can_edit_by_owner_only')
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_url, notice: I18n.t('views.messages.delete_team')
  end

  def dashboard
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
  end

  def change_owner
    # 権限を移動するアサインユーザーを取得
    @assign = Assign.find(params[:id])
    # AssignからTeamのIDを取得
    @team = Team.friendly.find(@assign.team_id)

    # オーナーが操作しているか確認
    if current_user.id == @team.owner_id
      if @team.update_attribute(:owner_id, @assign.user_id)
        # 権限を移動するユーザにメールを送信

        # リダイレクト
        redirect_to @team, notice: I18n.t('views.messages.change_owner')
      else
        flash.now[:error] = I18n.t('views.messages.failed_to_change_owner')
        render
      end
    else
      redirect_to @team, notice: I18n.t('views.messages.can_change_owner_by_current_owner_only')
    end
  end

  private

  def set_team
    @team = Team.friendly.find(params[:id])
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id]
  end
end
