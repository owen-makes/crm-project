class Lead < ApplicationRecord
  belongs_to :user
  belongs_to :team, optional: true
  include Exportable

  before_create :set_status, :set_team
  validates :name, :last_name, :email, :phone, presence: true

  enum status: {
    nuevo: "Nuevo",
    wip: "WIP",
    convertido: "Cerrado",
    baja: "Baja"
  }

  scope :filter_by_status, ->(status) { where(status: status) if status.present? }
  scope :converted, -> { where(status: "Cerrado") }
  scope :lost, -> { where(status: "Baja") }
  scope :active, -> { where(status: "WIP") }
  scope :fresh, -> { where(status: "Nuevo") }
  scope :excluding_converted, -> { where.not(status: "Cerrado") }


  def convert_to_client
    transaction do
      client = Client.from_lead(self)
      update!(status: :convertido)
      client
    end
    # Transactions are protective blocks where SQL statements are only permanent if they can all succeed as one atomic action.
    # Transactions enforce the integrity of the database and guard the data against program errors or database break-downs.
    # So basically you should use transaction blocks whenever you have a number of statements that must be executed together or not at all.
  end

  def full_name
    "#{self.name} #{self.last_name}"
  end

  private

  def set_status
    self.status = "Nuevo"
  end

  def set_team
    if self.user.team
      self.team_id = self.user.team.id
    end
  end
end
