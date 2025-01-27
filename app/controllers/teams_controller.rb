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

  private

  def set_team
    @team = current_user.team
    # .includes(:members)
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
