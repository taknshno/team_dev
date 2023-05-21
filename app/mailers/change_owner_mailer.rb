class ChangeOwnerMailer < ApplicationMailer
  def change_owner_mail(user, team)
    @user = user
    @team = team

    mail to: @user.email, subject: I18n.t('views.messages.leader_transferred_to_you')
  end
end