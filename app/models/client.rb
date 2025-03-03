class Client < ApplicationRecord
  belongs_to :user
  belongs_to :team, optional: true
  has_many :portfolios
  include Exportable
  after_create :set_team
  validates :name, :last_name, :phone, presence: true

  def self.from_lead(lead)
    create!(
      name: lead.name,
      last_name: lead.last_name,
      phone: lead.phone,
      channel: lead.channel,
      broker: lead.broker,
      email: lead.email,
      notes: lead.notes,
      goals: lead.description,
      team_id: lead.team_id,
      user_id: lead.user_id
    )
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
end
