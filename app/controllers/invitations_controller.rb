class InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def new
    @team = current_user.team.reload
    @invitation = Invitation.new
  end

  def create
    @invitation = current_user.managed_team.invitations.new(
                  invitation_params.merge(sender: current_user))
    @team = current_user.team.reload

    if @invitation.save
      # Send an email with the invitation link
      InvitationMailer.invite(@invitation, @team).deliver_now!
      redirect_to team_path(current_user.managed_team), notice: "Invitation sent!"
    else
      render :new, alert: "Error sending invitation."
    end
  end

  def accept
    @invitation = Invitation.find_by(token: params[:token])

    if @invitation && @invitation.status == "pending"
      @invitation.update(status: "accepted")
      @user = User.create!(email: @invitation.email, password: Devise.friendly_token[0, 20], team: @invitation.team, role: :member)
      sign_in(@user)
      redirect_to root_path, notice: "Welcome to the team!"
    else
      redirect_to root_path, alert: "Invalid or expired invitation."
    end
  end

  private

  def invitation_params
    params.require(:invitation).permit(:email)
  end

  def authorize_admin!
    redirect_to root_path, alert: "You are not authorized to send invitations." unless current_user.admin?
  end
end
