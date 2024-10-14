class BranchPolicy < ApplicationPolicy
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
        scope.where(id: user.branch_id)
      else
        scope.none
      end
    end
  end

  def index?
    user.present? && (user.super_admin? || user.branch_admin? || user.cashier?)
  end

  def show?
    user.super_admin? || (user.branch_admin? && user.branch_id == record.id)
  end
  
  def create?
    user.super_admin?
  end

  def update?
    user.super_admin? || (user.branch_admin? && user.branch_id == record.id)
  end

  def destroy?
    user.super_admin?
  end








end
