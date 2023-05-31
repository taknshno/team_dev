class AgendaDeleteMailer < ApplicationMailer
  def agenda_delete_mail(agenda)
    @agenda = agenda
    @team = Team.friendly.find(@agenda.team_id)

    mail to: @team.members.pluck(:email), subject: I18n.t('views.messages.delete_agenda')
  end
end
