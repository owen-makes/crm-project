# frozen_string_literal: true

class AddbuttonComponent < ViewComponent::Base
  attr_reader :label, :link, :data, :classes

  DEFAULT_CLASSES =
    "inline-flex items-center px-3 py-1.5 border border-black rounded-md
     font-medium text-xs hover:bg-slate-50 focus:outline-none
     focus:ring-2 focus:ring-offset-2 focus:ring-green-500".squish.freeze

  def initialize(label: "Nuevo", link:, data: {}, classes: DEFAULT_CLASSES)
    @label   = label
    @link    = link
    @data    = data.compact_blank
    @classes = classes
  end
end
