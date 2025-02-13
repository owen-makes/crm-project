class CsvImportPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  # Admins can perform all actions
  def new?
    user.admin?
  end

  def create?
    new?
  end

  def map_headers?
    new?
  end

  def choose_rows?
    new?
  end

  def import?
    new?
  end


  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.where(id: user.team_id)
    end
  end
end
