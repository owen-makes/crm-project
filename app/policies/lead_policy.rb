class LeadPolicy < ApplicationPolicy
  class Scope < Scope
    # scope: Represents the collection of resources Lead.all
    # resolve: Defines how the collection should be filtered based on the user's role.
    def resolve
      if admin_with_team?
        scope.joins(:user).where(users: { team_id: user.team_id })
      else
        scope.where(user: user)
      end
    end

    private

    def admin_with_team?
      user.admin? && user.team_id.present?
    end
  end

  # ---- PERMISSIONS ---------------------------------------------------------

  def show?
    admin_with_team? ? same_team? : owns_record?
  end

  def assign?
    admin_with_team? && same_team?
  end

  alias_method :edit?,    :show?
  alias_method :update?,  :show?
  alias_method :destroy?, :show?

  # ---- HELPERS -------------------------------------------------------------

  private

  def admin_with_team?
    user.admin? && user.team_id.present?
  end

  def same_team?
    record.user&.team_id == user.team_id
  end

  def owns_record?
    record.user_id == user.id
  end
end
