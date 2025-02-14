module Exportable
  extend ActiveSupport::Concern
  require "csv"

  class_methods do
    def to_csv(records = nil)
      records ||= all

      CSV.generate(headers: true) do |csv|
        csv << column_names

        records.each do |record|
          # Convert timestamps to a more readable format
          row = column_names.map do |attr|
            value = record.send(attr)
            case value
            when ActiveSupport::TimeWithZone
              value.strftime("%Y-%m-%d %H:%M:%S")
            else
              value
            end
          end

          csv << row
        end
      end
    end
  end
end
