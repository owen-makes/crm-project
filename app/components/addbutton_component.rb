# frozen_string_literal: true

class AddbuttonComponent < ViewComponent::Base
  attr_reader :label, :link

  def initialize(label: "Nuevo", link:, turbo_frame: nil)
    @label = label
    @link = link
    @turbo_frame = turbo_frame  # Pass the name of the turbo frame
  end
end
