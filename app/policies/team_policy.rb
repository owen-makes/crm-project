class TeamPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  # Admins can perform all actions
  def index?
    user.admin?
  end

  def show?
    user.admin? || record.members.include?(user)
  end

  def create?
    user.admin?
  end

  def new?
    create?
  end

  def update?
    user.admin? && record.admin == user
  end

  def edit?
    update?
  end

  def destroy?
    user.admin? && record.admin == user
  end

  # Members can join a team
  def join?
    user.member? && record.persisted?
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.where(id: user.team_id)
    end
  end
end
