class Lead < ApplicationRecord
  belongs_to :user
  before_create :set_status
  validates :name, :last_name, :email, :phone, presence: true

  def convert_to_client
    transaction do
      client = Client.from_lead(self)
      update!(status: "Converted")
      client
    end
    # Transactions are protective blocks where SQL statements are only permanent if they can all succeed as one atomic action.
    # The classic example is a transfer between two accounts where you can only have a deposit if the withdrawal succeeded and vice versa.
    # Transactions enforce the integrity of the database and guard the data against program errors or database break-downs. So basically you should use transaction blocks whenever you have a number of statements that must be executed together or not at all.
  end

  private

  def set_status
    self.status = "Open"
  end
end
