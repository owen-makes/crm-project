class InvitationMailer < ApplicationMailer
  def invite(invitation)
    @invitation = invitation
    @url = accept_invitation_url(token: invitation.token)
    mail(to: @invitation.email, subject: "Te invitaron a unirte a #{invitation.team.name}")
  end
end
