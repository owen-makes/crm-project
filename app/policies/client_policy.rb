class ClientPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.joins(:user).where(users: { team_id: user.team_id })
      else
        scope.where(user: user)
      end
    end
  end
  # scope: Represents the collection of resources Lead.all
  # resolve: Defines how the collection should be filtered based on the user's role.

  def show?
    # Members can only see their leads; admins can see any lead in their team
    user.admin? ? record.user.team == user.team : record.user == user
  end

  def assign?
    # Admin can assign if the lead is in their team
    user.admin? && record.user.team == user.team
  end

  def edit?
    show?
  end

  def update?
    show?
  end

  def destroy?
    show?
  end
end
