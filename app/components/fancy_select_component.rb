# frozen_string_literal: true

class FancySelectComponent < ViewComponent::Base
  attr_reader :label, :items, :form_name

  def initialize(label:, items: [], form_name:)
    @label = label
    @items = items
    @form_name = form_name
  end

  class Item < Struct.new(:id, :label, :image_url); end
end
