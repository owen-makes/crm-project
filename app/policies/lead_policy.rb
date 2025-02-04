class LeadPolicy < ApplicationPolicy
  # By default, only allow team members to manage their own leads
  def update?
    user.admin? || record.user_id == user.id
  end

  def assign?
    # Only admin users can assign leads
    user.admin?
  end

  def destroy?
    # For example, team members may not be allowed to destroy leads
    user.admin?
  end

  # The index? and show? methods can also be defined here
  def show?
    user.admin? || record.user_id == user.id
  end

  class Scope < Scope
    def resolve
      # Team members only see their own leads, while admins see all leads in their team.
      if user.admin?
        scope.where(user_id: user.team.users.pluck(:id))
      else
        scope.where(user_id: user.id)
      end
    end
  end
end
