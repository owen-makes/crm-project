class Users::InvitationsController < Devise::InvitationsController
  before_action :authorize_admin!, only: [ :new, :create ]
  before_action :configure_permitted_parameters
  skip_before_action :resource_from_invitation_token, only: [ :destroy ]
  skip_before_action :authenticate_inviter!, only: [ :destroy ]
  skip_before_action :has_invitations_left?, only: [ :destroy ]
  skip_before_action :require_no_authentication, only: [ :destroy ]


  def accept_invitation
    super do |resource|
      if session[:invited_team_id]
        resource.update(team_id: session[:invited_team_id])
        session.delete(:invited_team_id)
      end
    end
  end

  def destroy
    user = User.find(params[:id])

    if user.invited_to_sign_up? && !user.invitation_accepted?
      team = user.team # Store the team before deletion
      user.destroy
      redirect_to team_path(team), notice: "Invitation cancelled successfully"
    else
      redirect_to root_path, alert: "Cannot delete this user"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "User not found"
  end

  private

  def invite_resource
    super do |user|
      user.skip_invitation = false
      # If the invitation was sent by a team admin, assign their team
      user.team = current_user.team if current_user&.admin?
    end
  end

  def devise_mapping
    Devise.mappings[:user]
  end

    def authorize_admin!
      redirect_to root_path, alert: "You are not authorized to send invitations." unless current_user.admin?
    end

    # Permit the new params here.
    def configure_permitted_parameters
      # For sending invitations
      devise_parameter_sanitizer.permit(:invite, keys: [ :first_name, :last_name, :role, :team_id ])

      # For accepting invitations
      devise_parameter_sanitizer.permit(:accept_invitation, keys: [ :name, :last_name, :role, :password, :password_confirmation ])
    end
end
