class Lead < ApplicationRecord
  belongs_to :user
  belongs_to :team, optional: true

  before_create :set_status
  validates :name, :last_name, :email, :phone, presence: true

  enum status: { nuevo: 0, en_progreso: 1, convertido: 2, cerrado: 3 }

  def convert_to_client
    transaction do
      client = Client.from_lead(self)
      update!(status: 3)
      client
    end
    # Transactions are protective blocks where SQL statements are only permanent if they can all succeed as one atomic action.
    # Transactions enforce the integrity of the database and guard the data against program errors or database break-downs.
    # So basically you should use transaction blocks whenever you have a number of statements that must be executed together or not at all.
  end

  private

  def set_status
    self.status = 0
  end
end
