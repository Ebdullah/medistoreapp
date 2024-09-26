class RecordPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.super_admin?
        scope.all
      elsif user.branch_admin? || user.cashier?
        scope.where(branch_id: user.branch_id)
      else
        scope.none
      end
    end
  end

  def index?
    user.super_admin? || user.branch_admin? || user.cashier?
  end

  def show?
    user.super_admin? || user.branch_admin? || (user.cashier? && record.branch_id == user.branch_id)
  end

  def create?
    user.super_admin? || (user.branch_admin? || user.cashier?)
  end

  def update?
    user.super_admin? || (user.branch_admin? || (user.cashier? && record.branch_id == user.branch_id))
  end

  def destroy?
    user.super_admin? || user.branch_admin?
  end
end
