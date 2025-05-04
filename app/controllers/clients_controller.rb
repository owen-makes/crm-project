class ClientsController < ApplicationController
  before_action :set_client, only: %i[ show edit update destroy ]

  # GET /clients or /clients.json
  def index
    @clients = policy_scope(Client).includes(:user)

    # Apply filters
    @clients = @clients.where("clients.name ILIKE ? OR clients.last_name ILIKE ?", "%#{params[:query]}%", "%#{params[:query]}%") if params[:query].present?
    @clients = @clients.filter_by_broker(params[:broker]) if params[:broker].present?
    @clients = @clients.where(user_id: params[:user_id]) if params[:user_id].present?

    # Date range filter
    if params[:date_from].present?
      date_from = Date.parse(params[:date_from]).beginning_of_day
      @clients = @clients.where("clients.created_at >= ?", date_from)
    end

    if params[:date_to].present?
      date_to = Date.parse(params[:date_to]).end_of_day
      @clients = @clients.where("clients.created_at <= ?", date_to)
    end

    # Sorting
    if params[:sort].present?
      direction = params[:direction] == "desc" ? "desc" : "asc"

      case params[:sort]
      when "name"
        @clients = @clients.order(name: direction, last_name: direction)
      when "user_id"
        @clients = @clients.joins(:user).order("users.name #{direction}, users.last_name #{direction}")
      else
        @clients = @clients.order(params[:sort] => direction)
      end
    else
      # Default sort by created_at desc
      @clients = @clients.order(created_at: :desc)
    end

    # Pagination
    @clients = @clients.page(params[:page]).per(15)

    respond_to do |format|
      format.html
      format.csv { send_data @clients.to_csv, filename: "clients-#{Time.current.strftime("%Y%m%d")}.csv" }
    end
  end

  # GET /clients/1 or /clients/1.json
  def show
    @prices = {}
    @client.portfolios.includes(holdings: :security).each do |portfolio|
      tickers = portfolio.holdings.map { |h| h.security.ticker }
      @prices[portfolio.id] = Data912::ApiService.new.live_price_bulk(tickers)
    end
  end


  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients or /clients.json
  def create
    @client = current_user.clients.build(client_params)

    respond_to do |format|
      if @client.save
        format.html { redirect_to @client, notice: "Client was successfully created." }
        format.json { render :show, status: :created, location: @client }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clients/1 or /clients/1.json
  def update
    respond_to do |format|
      if @client.update(client_params)
        format.html { redirect_to @client, notice: "Client was successfully updated." }
        format.json { render :show, status: :ok, location: @client }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clients/1 or /clients/1.json
  def destroy
    @client.destroy!

    respond_to do |format|
      format.html { redirect_to clients_path, status: :see_other, notice: "Client was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def client_params
      params.require(:client).permit(:name, :last_name, :phone, :channel, :broker, :email, :notes, :goals, :user_id)
    end
end
