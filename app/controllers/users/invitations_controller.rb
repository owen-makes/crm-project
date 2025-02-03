class Users::InvitationsController < Devise::InvitationsController
  before_action :authorize_admin!, only: [ :new, :create ]
  before_action :configure_permitted_parameters

  def accept_invitation
    super do |resource|
      if session[:invited_team_id]
        resource.update(team_id: session[:invited_team_id])
        session.delete(:invited_team_id)
      end
    end
  end

  private

  def invite_resource
    super do |user|
      user.skip_invitation = false
      # If the invitation was sent by a team admin, assign their team
      user.team = current_user.team if current_user&.admin?
    end
  end

    # This is called when accepting invitation.
    # It should return an instance of resource class.
    # def accept_resource
    #   resource = resource_class.accept_invitation!(update_resource_params)
    #   resource
    # end

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
