class TeamsController < ApplicationController
  before_action :set_team, only: [ :show, :edit, :update, :destroy, :join ]
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

  def join
    # authorize @team
    if @team.members << current_user
      redirect_to @team, notice: "You have successfully joined the team."
    else
      redirect_to teams_url, alert: "Unable to join the team."
    end
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
        current_user.update(team: @team)
        redirect_to team_path(@team), notice: "You've joined #{@team.name}!"
      end
    else
      session[:invited_team_id] = @team.id  # Store team ID in session
      redirect_to new_user_registration_path, notice: "You've been invited to join #{@team.name}. Please sign up below."
    end
  end

  private

  def set_team
    @team = current_user.team
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
