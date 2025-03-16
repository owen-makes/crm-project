class Exchange < ApplicationRecord
  has_many :securities
  validates :mic_code, presence: :true, uniqueness: true

  # create_table "exchanges", force: :cascade do |t|
  #   t.string "name"
  #   t.string "country_code"
  #   t.string "acronym"
  #   t.string "mic_code"
  #   t.string "city"
  #   t.datetime "created_at", null: false
  #   t.datetime "updated_at", null: false
  # end
end
