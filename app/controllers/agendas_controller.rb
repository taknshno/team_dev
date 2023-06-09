class AgendasController < ApplicationController
  before_action :set_agenda, only: %i[show edit update destroy]

  def index
    @agendas = Agenda.all
  end

  def new
    @team = Team.friendly.find(params[:team_id])
    @agenda = Agenda.new
  end

  def create
    @agenda = current_user.agendas.build(title: params[:title])
    @agenda.team = Team.friendly.find(params[:team_id])
    current_user.keep_team_id = @agenda.team.id
    if current_user.save && @agenda.save
      redirect_to dashboard_url, notice: I18n.t('views.messages.create_agenda') 
    else
      render :new
    end
  end

  def destroy
    @team = Team.friendly.find(@agenda.team_id)
    if current_user.id == @agenda.user_id || current_user.id == @team.owner_id
      if @agenda.destroy
        AgendaDeleteMailer.agenda_delete_mail(@agenda).deliver
        redirect_to dashboard_url, notice: I18n.t('views.messages.delete_agenda')
      else
        flash.now[:error] = I18n.t('views.messages.failed_to_delete_agenda')
        render
      end
    else
      redirect_to dashboard_url, notice: I18n.t('views.messages.can_delete_agenda_by_creator_or_leader')
    end
  end

  private

  def set_agenda
    @agenda = Agenda.find(params[:id])
  end

  def agenda_params
    params.fetch(:agenda, {}).permit %i[title description]
  end
end
