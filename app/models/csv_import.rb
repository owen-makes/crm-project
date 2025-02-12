class CsvImport < ApplicationRecord
  require "CSV"
  scope :expired, -> { where("created_at < ?", 1.day.ago) }
  belongs_to :user
  belongs_to :team

  mount_uploader :file, CsvUploader

  validates :file, presence: true

  def parse_csv
    return if headers.present?

    begin
      # First, let's check if we can read the file
      Rails.logger.debug("Attempting to read file: #{file.path}")

      # Read the CSV with explicit UTF-8 encoding
      csv_content = CSV.read(file.path, encoding: "bom|utf-8")

      Rails.logger.debug("CSV Content: #{csv_content.inspect}")

      if csv_content.blank? || csv_content.first.blank?
        errors.add(:file, "appears to be empty or malformed")
        return false
      end

      # Process headers - handle nil values
      self.headers = csv_content.first.map { |header| header.to_s.strip }

      Rails.logger.debug("Headers after processing: #{self.headers.inspect}")

      # Process data - handle nil values
      self.data = csv_content.drop(1).map do |row|
        row.map { |cell| cell.to_s.strip }
      end

      Rails.logger.debug("Data rows count: #{self.data.size}")

      save
    rescue CSV::MalformedCSVError => e
      Rails.logger.error("CSV Parsing Error: #{e.message}")
      errors.add(:file, "is not a valid CSV file: #{e.message}")
      false
    rescue Encoding::UndefinedConversionError => e
      Rails.logger.error("Encoding Error: #{e.message}")
      errors.add(:file, "has encoding issues. Please ensure it's saved as UTF-8")
      false
    rescue => e
      Rails.logger.error("Unexpected Error: #{e.message}")
      errors.add(:file, "could not be processed: #{e.message}")
      false
    end
  end

  def import_records(record_type, mapped_headers)
    klass = record_type.classify.constantize

    data.map do |row|
      attributes = {}

      mapped_headers.each do |csv_header, db_field|
        next if db_field.blank?
        column_index = headers.index(csv_header)
        attributes[db_field] = row[column_index] if column_index
      end

      attributes.merge!(
        user_id: user_id,
        team_id: team_id
      )

      klass.create(attributes)
    end

    destroy # Clean up after successful import
  end

  def self.clean_up!
    expired.destroy_all
  end
end
