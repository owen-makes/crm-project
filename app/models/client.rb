class Client < ApplicationRecord
  belongs_to :user
  validates :name, :last_name, :phone, :email, presence: true

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
      user_id: lead.user_id
    )
  end
end
