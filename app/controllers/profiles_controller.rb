class ProfilesController < ApplicationController
  before_action :set_user, only: [ :show ]
  before_action :authorize_profile_access!

  def show
    @profile = @user.profile
    @user_clients = @user.clients
    @user_leads = @user.leads

    # Preload portfolios and holdings for performance
    @user_portfolios = Portfolio.joins(client: :user)
                               .where(clients: { user_id: @user.id })
                               .includes(:holdings)
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to profile_path, notice: "Profile updated successfully"
    else
      render :edit
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def authorize_profile_access!
    unless current_user.admin? || current_user == @user
      redirect_to root_path, alert: "Not authorized"
    end
  end

  def profile_params
    params.require(:profile).permit(:settings)
    # settings: [:theme_preference, :language_preference]
  end
end
