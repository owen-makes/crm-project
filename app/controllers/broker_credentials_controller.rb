class BrokerCredentialsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_team_admin!
  before_action :set_team
  before_action :set_credential, only: %i[edit update destroy]
  # ---------- RESTful actions ----------

  def index
    @credentials = @team.broker_credentials.all
  end

  def new
    @credential = @team.broker_credentials.build
  end

  def create
    @credential = @team.broker_credentials.build(broker_credential_params)
    if @credential.save
      redirect_to team_path, notice: "Credencial guardada correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @credential.update(broker_credential_params)
      redirect_to team_path, notice: "Credencial actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @credential.destroy
    flash[:provider] = @credential.provider
    redirect_to team_path, notice: "Se desconectó #{@credential.provider}"
  end

  private

  def set_credential
    @credential = BrokerCredential.find(params[:id])
  end

  def set_team
    @team = current_user.team
  end

  def broker_credential_params
    params.require(:broker_credential)
          .permit(:access_token, :refresh_token, :token_expires_at, :account_number, :username, :password)
  end

  def require_team_admin!
    redirect_to root_path, alert: "Acceso denegado." unless current_user.admin?
  end
end
