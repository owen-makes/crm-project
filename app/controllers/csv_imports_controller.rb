class CsvImportsController < ApplicationController
  def new
    @csv_import = CsvImport.new
  end

  def create
    @csv_import = current_user.csv_imports.build(csv_import_params)
    @csv_import.team = current_user.managed_team

    if @csv_import.save
      @csv_import.parse_csv

      redirect_to map_headers_csv_import_path(@csv_import, record_type: params[:record_type])
    else
      render :new
    end
  end

  def map_headers
    @csv_import = CsvImport.find(params[:id])
    @record_type = params[:record_type]

    @available_fields = case params[:record_type]
    when "clients"
      Client.column_names - %w[id created_at updated_at user_id team_id]
    when "leads"
      Lead.column_names - %w[id created_at updated_at user_id team_id]
    else
      Rails.logger.error("Invalid record type: #{params[:record_type]}")
      []
    end
  end

  def choose_rows
    @csv_import = CsvImport.find(params[:id])
    @mapped_headers = @csv_import.headers.zip(params[:headers]).to_h
    @record_type = params[:record_type]

    @preview_data = @csv_import.data.map do |row|
      row_data = {}
      @mapped_headers.each do |csv_header, db_field|
        next if db_field.blank?
        column_index = @csv_import.headers.index(csv_header)
        row_data[db_field] = row[column_index] if column_index
      end
      row_data
    end

    # Debug the headers
    Rails.logger.debug "Headers: #{@csv_import.headers.inspect}"
    Rails.logger.debug "Mapped headers: #{@mapped_headers.inspect}"
    Rails.logger.debug "Record type: #{@record_type}"
    Rails.logger.debug "Selected rows: #{params[:selected_rows].inspect}"
  end

  def import
    @csv_import = CsvImport.find(params[:id])
    klass = params[:record_type].classify.constantize
    mapped_headers = @csv_import.headers.zip(params[:headers]).to_h
    selected_rows = params[:selected_rows].map(&:to_i)

    selected_rows.each do |row_index|
      row = @csv_import.data[row_index]
      attributes = {}

      mapped_headers.each do |csv_header, db_field|
        next if db_field.blank?
        column_index = @csv_import.headers.index(csv_header)
        attributes[db_field] = row[column_index] if column_index
      end

      attributes.merge!(
        user_id: current_user.id,
        team_id: current_user.team_id
      )

      klass.create(attributes)
    end

    @csv_import.destroy # Clean up after successful import
    redirect_to root_path, notice: "#{selected_rows.size} records imported successfully!"
  rescue => e
    Rails.logger.error("Import Error: #{e.message}")
    redirect_to choose_rows_csv_import_path(@csv_import), alert: "Error during import. Please try again."
  end

  private

  def csv_import_params
    params.require(:csv_import).permit(:file, :record_type)
  end
end
