class LeadsController < ApplicationController
  before_action :set_lead, only: [ :show, :edit, :update, :destroy, :convert ]
  before_action :authenticate_user!, only: [ :index, :show, :update, :destroy ]
  def index
    @leads = policy_scope(Lead).includes(:user)

    case params[:status]
    when "converted"
      @leads = @leads.converted
    when "lost"
      @leads = @leads.lost
    when "active"
      @leads = @leads.active
    end
  end

  def show
    authorize @lead
  end

  def assign
    @lead = Lead.find(params[:id])
    # Only allow admin to assign leads to a team member
    authorize @lead, :assign?
    assigned_user = User.find_by(id: params[:assigned_user_id])

    # Ensure assigned user is part of the admin's team
    unless assigned_user && current_user.team.members.include?(assigned_user)
      redirect_to leads_path, alert: "Cannot assign lead to a user outside your team."
      return
    end

    # The form should submit the new user_id as :assigned_user_id
    if @lead.update(user_id: params[:assigned_user_id])
      redirect_to leads_path, notice: "Lead assigned successfully."
    else
      redirect_to leads_path, alert: "Assignment failed."
    end
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

    if @lead.convertido?
      redirect_to clients_path, alert: "Este lead ya fue convertido a cliente"
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
