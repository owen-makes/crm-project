class Portfolio < ApplicationRecord
  belongs_to :client
  has_many :holdings

  def total_value
    holdings.sum(&:current_value)
  end

  def holdings_with_metrics
    holdings.map do |holding|
      {
        holding: holding,
        current_value: holding.current_value,
        percentage: holding.percentage_of_portfolio,
        profit_loss: holding.profit_loss,
        profit_loss_percentage: holding.profit_loss_percentage
      }
    end
  end
end
