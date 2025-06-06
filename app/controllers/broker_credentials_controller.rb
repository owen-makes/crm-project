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
      AuthenticateBrokerCredentialJob.perform_later(@credential.id)
      flash.now[:notice] = "#{@credential.provider_display_name} conectado, validando credenciales"
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("flash", partial: "partials/flash"),
            turbo_stream.update("modal") { "" } ]
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @credential.update(broker_credential_params)
      AuthenticateBrokerCredentialJob.perform_later(@credential.id)
      flash.now[:notice] = "Credencial Actualizada"
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("flash", partial: "partials/flash"),
            turbo_stream.update("modal") { "" } ]
        end
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @credential.destroy
    flash.now[:notice] = "Se desconectó #{@credential.provider_display_name}"
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("flash", partial: "partials/flash"),
          turbo_stream.update("modal") { "" } ]
      end
    end
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
          .permit(:access_token, :refresh_token, :token_expires_at, :account_number, :username, :password, :provider)
  end

  def require_team_admin!
    redirect_to root_path, alert: "Acceso denegado." unless current_user.admin?
  end
end
