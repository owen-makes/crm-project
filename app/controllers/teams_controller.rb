class TeamsController < ApplicationController
  before_action :set_team, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_admin!, only: [ :new, :create, :edit, :update, :destroy ]
  def show
    # authorize @team
  end

  def new
    @team = Team.new
    # authorize @team
  end

  def create
    @team = Team.new(team_params)
    @team.admin = current_user
    # authorize @team

    if @team.save
      redirect_to @team, notice: "Team was successfully created."
    else
      render :new
    end
  end

  def edit
    # authorize @team
  end

  def update
    # authorize @team
    if @team.update(team_params)
      redirect_to @team, notice: "Team was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    # authorize @team
    @team.destroy
    redirect_to teams_url, notice: "Team was successfully destroyed."
  end

  def join_via_link
    @team = Team.find_by(join_token: params[:token])

    if @team.nil?
      redirect_to root_path, alert: "Invalid invitation link."
      return
    end

    if user_signed_in?
      if @team.members.include?(current_user)
        redirect_to team_path(@team), notice: "You're already part of this team."
      else
        current_user.update(team: @team, role: "member")
        redirect_to team_path(@team), notice: "You've joined #{@team.name}!"
      end
    else
      session[:invited_team_id] = @team.id  # Store team ID in session
      redirect_to new_user_registration_path, notice: "You've been invited to join #{@team.name}. Please sign up below."
    end
  end

  def remove_from_team
    @user = User.find(params[:id])

    if current_user.admin? && @user != current_user
      @user.remove_from_team(reassign_to: current_user)
      redirect_to team_path(current_user.team), notice: "Member removed from team"
    else
      redirect_to root_path, alert: "Not authorized"
    end
  end

  private

  def set_team
    @team = current_user.team
  end

  def team_params
    params.require(:team).permit(:name)
  end

  def authorize_admin!
    redirect_to root_path, alert: "You are not authorized." unless current_user.admin?
  end
end
