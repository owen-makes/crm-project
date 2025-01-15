class LeadsController < ApplicationController
  before_action :set_lead, only: [ :show, :edit, :update, :destroy ]
  before_action :authenticate_user!, only: [ :index, :show, :update, :destroy ]
  def index
    @leads = current_user.leads
  end

  def show
  end

  def new
    @user = User.find_by(form_token: params[:form_token])
    redirect_to root_path, alert: "Form not found" unless @user
    @lead = Lead.new
  end

  def create
    @user = User.find_by(form_token: params[:form_token])
    redirect_to root_path, alert: "Form not found" unless @user
    @lead = @user.leads.new(lead_params)
    if @lead.save
      render "thank_you", status: :ok
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @lead.update(lead_params)
      redirect_to leads_path, notice: "Lead was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @lead.destroy
    redirect_to leads_path, notice: "Lead was successfully deleted."
  end

  private

  def set_lead
    @lead = Lead.find(params[:id])
  end

  def lead_params
    params.require(:lead).permit(:name, :last_name, :email, :phone, :capital, :description)
  end
end
