class LeadsController < ApplicationController
  before_action :set_lead, only: [ :show, :edit, :update, :destroy ]
  before_action :authenticate_user!, only: [ :index, :show, :update, :destroy ]
  def index
    @leads = current_user.leads.where.not(" status = ?", "Converted")
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
      flash[:lead_id] = @lead.id
      redirect_to thank_you_path(format: nil)
    else
      render :new
    end
  end

  def convert
    @lead = Lead.find(params[:id])

    if @lead.status == "Converted"
      redirect_to clients_path, alert: "This lead has already been converted to a client."
      return
    end

    @client = @lead.convert_to_client
    redirect_to client_path(@client), notice: "Lead successfully converted to a client."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to lead_path(@lead), alert: "Conversion failed: #{e.message}"
  end

  def thank_you
    @lead = Lead.find(flash[:lead_id])
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
    params.require(:lead).permit(:name, :last_name, :email, :phone, :capital, :description, :broker, :notes, :channel, :status)
  end
end
