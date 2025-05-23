class LeadsController < ApplicationController
  require "uri"
  before_action :set_lead, only: [ :show, :edit, :update, :destroy, :convert ]
  before_action :authenticate_user!, only: [ :index, :show, :update, :destroy ]
  def index
    @leads = policy_scope(Lead).includes(:user)

    # Apply filters
    @leads = @leads.where("leads.name ILIKE ? OR leads.last_name ILIKE ?", "%#{params[:query]}%", "%#{params[:query]}%") if params[:query].present?
    @leads = @leads.where(broker: params[:broker]) if params[:broker].present?
    @leads = @leads.where("capital >= ?", params[:min_capital]) if params[:min_capital].present?
    @leads = @leads.where(user_id: params[:user_id]) if params[:user_id].present?

    # Date range filter
    if params[:date_from].present?
      date_from = Date.parse(params[:date_from]).beginning_of_day
      @leads = @leads.where("leads.created_at >= ?", date_from)
    end

    if params[:date_to].present?
      date_to = Date.parse(params[:date_to]).end_of_day
      @leads = @leads.where("leads.created_at <= ?", date_to)
    end

    # Status filter
    case params[:status]
    when "active"
      @leads = @leads.active
    when "converted"
      @leads = @leads.converted
    when "lost"
      @leads = @leads.lost
    when "fresh"
      @leads = @leads.fresh
    else
      @leads = @leads.excluding_converted
    end

    # Sorting
    if params[:sort].present?
      direction = params[:direction] == "desc" ? "desc" : "asc"

      case params[:sort]
      when "name"
        @leads = @leads.order(name: direction, last_name: direction)
      when "user_id"
        @leads = @leads.joins(:user).order("users.name #{direction}, users.last_name #{direction}")
      else
        @leads = @leads.order(params[:sort] => direction)
      end
    else
      # Default sort by created_at desc
      @leads = @leads.order(created_at: :desc)
    end

    # Pagination
    @leads = @leads.page(params[:page]).per(15)

    respond_to do |format|
      format.html
      format.csv { send_data @leads.to_csv, filename: "leads-#{Time.current.strftime("%Y%m%d")}.csv" }
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
    @lead = @user.leads.build(lead_params)

    @lead.channel       ||= infer_channel
    @lead.source_detail ||= infer_source_detail
    @lead.campaign      ||= params[:utm_campaign]
    @lead.channel       ||= :otro

    if @lead.save
      flash[:lead_id] = @lead.id
      redirect_to thank_you_path(format: nil)
    else
      render :new
    end
  end

  def convert
    if @lead.convertido?
      redirect_to clients_path, alert: "Este lead ya fue convertido a cliente"
      return
    end

    @client = @lead.convert_to_client
    redirect_to client_path(@client), notice: "#{@client.full_name} fue convertido a cliente!"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to lead_path(@lead), alert: "Falló la conversión: #{e.message}"
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

  def infer_channel
    # UTM tag
    case params[:utm_medium]&.downcase
    when "cpc", "ppc" then :publicidad
    when "social"     then :redes
    when "email"      then :email
    end ||

    # UTM source when medium is missing
    case params[:utm_source]&.downcase
    when /instagram|tiktok|facebook|linkedin|youtube/ then :redes
    when /google_ads/                                then :publicidad
    end ||

    # Referrer host
    channel_from_referrer(request.referer)
  end

  def channel_from_referrer(url)
    host = extract_domain(url)
    return :busqueda if host&.match?(/google\./)
    return :redes    if host&.match?(/instagram\.com|tiktok\.com|
                                      facebook\.com|linkedin\.com|youtube\.com/x)
    nil
  end

  def infer_source_detail
    params[:utm_source].presence ||
      extract_domain(request.referer)
  end

  def extract_domain(url)
    URI.parse(url).host if url.present?
  end

  def lead_params
    params.require(:lead).permit(:name, :last_name, :email, :phone, :capital,
                               :description, :broker, :notes, :channel, :status,
                               :source_detail, :campaign)
  end
end
