class LeadController < ApplicationController
  before_action :set_lead, only: [ :show, :edit, :update, :destroy ]

  def index
    @leads = Lead.all
  end

  def show
  end

  def new
    @lead = Lead.new
  end

  def create
    @lead = Lead.new(lead_params)

    if @lead.save
      redirect_to leads_path, notice: "Lead was successfully created."
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
    params.require(:lead).permit(:name)
  end
end
