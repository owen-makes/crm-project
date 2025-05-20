# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    super do |resource|
      if session[:invited_team_id]
        resource.update(team_id: session[:invited_team_id], role: "member")
        session.delete(:invited_team_id)
      end
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    # Devise helper that enforces current_password if you included that field
    resource_updated = update_resource(resource, account_update_params)

    if resource_updated
      flash[:notice] = "Perfil actualizado"

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("modal"),
            turbo_stream.update("profile-card",
                                 partial: "profiles/card",
                                 locals: { user: resource })
          ]
      end

        # Fallback for non-Turbo browsers
        format.html { redirect_to after_update_path_for(resource) }
      end
    else
      clean_up_passwords resource
      set_minimum_password_length

      respond_to do |format|
        format.turbo_stream { render :edit, layout: false, formats: :html, status: :unprocessable_entity }
      end
    end
  end



  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :last_name, :role ])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :last_name, :role, :emoji ])
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
