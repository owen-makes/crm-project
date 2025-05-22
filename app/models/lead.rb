class Lead < ApplicationRecord
  belongs_to :user
  belongs_to :team, optional: true
  include Exportable

  after_commit :convert_to_client, on: :update, if: :closed_now?
  before_create :set_team
  validates :name, :last_name, :email, :phone, presence: true
  validates :campaign, length: { maximum: 60 }, allow_blank: true
  validates :source_detail, length: { maximum: 20 }, allow_blank: true


  enum :status, {
    nuevo: 0,
    wip: 1,
    cerrado: 2,
    baja: 3
  }

  enum channel: {
    referido:   0,
    publicidad: 1,
    redes:      2,
    evento:     3,
    busqueda:   4,
    email:      5,
    otro:       6
  }, _prefix: true # means I need to call like lead.channel_X (i.e. lead.channel_evento?)


  scope :filter_by_status, ->(status) { where(status: status) if status.present? }
  scope :active,              -> { where(status: statuses[:wip]) }
  scope :converted,           -> { where(status: statuses[:cerrado]) }
  scope :lost,                -> { where(status: statuses[:baja]) }
  scope :fresh,               -> { where(status: statuses[:nuevo]) }
  scope :excluding_converted, -> { where.not(status: statuses[:cerrado]) }


  def convert_to_client
    transaction do
      client = Client.from_lead(self)
      update!(status: :cerrado)
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

  def set_team
    if self.user.team
      self.team_id = self.user.team.id
    end
  end

  def closed_now?
    saved_change_to_status? && cerrado?
  end
end
