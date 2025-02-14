class Client < ApplicationRecord
  belongs_to :user
  belongs_to :team, optional: true
  include Exportable

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
end
