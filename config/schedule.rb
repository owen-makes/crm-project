# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# # Set environment to the current Rails environment
# set :environment, Rails.env

# Set output log
set :output, "log/cron.log"

# Update security prices at 6PM on weekdays
# every "0 18 * * 1-5" do
#   runner "UpdateSecurityPricesJob.perform_now"
# end

# # Update exchange rates at 5PM on weekdays
# every "0 17 * * 1-5" do
#   runner "UpdateExchangeRatesJob.perform_now"
# end

every 1.day do
  runner "CsvImport.clean_up!"
end

# update prices
every 1.day, at: "5:30 am" do
  rake "data912:daily_update"
end
