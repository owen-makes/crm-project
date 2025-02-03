class Users::SessionsController < Devise::SessionsController
  def create
    super do |resource|
      if session[:invited_team_id]
        team = Team.find_by(id: session[:invited_team_id])
        if team
          resource.update(team: team, role: "member")
          session.delete(:invited_team_id)
          flash[:notice] = "Welcome to #{team.name}!"
        end
      end
    end
  end
end
