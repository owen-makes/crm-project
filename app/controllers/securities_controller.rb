class SecuritiesController < ApplicationController
  def index
    @securities = Security.all
  end

  def show
  end
end
