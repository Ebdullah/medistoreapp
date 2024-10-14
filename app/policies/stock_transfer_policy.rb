class StockTransferPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.super_admin?
        scope.where.not(pdf: nil)
      elsif user.branch_admin?
        scope.where(branch_id: user.branch_id)
      elsif user.cashier?
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
    user.super_admin? || user.branch_admin? || user.cashier?
  end

  def create?
    user.cashier?
  end

  def update?
    user.branch_admin?
  end

  def destroy?
    user.super_admin?
  end

  def approve?
    user.super_admin?
  end

  def deny?
    user.super_admin?
  end

  def pdf?
    user.branch_admin?
  end

  def upload_pdf?
    user.branch_admin?
  end
end
