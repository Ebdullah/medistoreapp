class BranchesController < ApplicationController
    before_action :authenticate_user!
    after_action :verify_authorized
    after_action :verify_policy_scoped, only: :index


    def index
        @branches = Branch.all
        @branches = policy_scope(Branch)
        authorize Branch
    end

    def show
        @branch = Branch.find(params[:id])
        @audit_logs = @branch.audit_logs
        authorize @branch
    end

    def new
        @branch = Branch.new
        authorize @branch
    end

    def create
        @branch = Branch.new(branch_params)
        authorize @branch
        if @branch.save
            redirect_to @branch, notice: "Branch was succesfully created."
        else
            render :new, status: :unprocessable_entity
        end
    end
    
    def edit
        @branch = Branch.find(params[:id])
        authorize @branch
    end

    def update
        @branch = Branch.find(params[:id])
        authorize @branch

        if @branch.update(branch_params)
            redirect_to @branch
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        authorize @branch
        @branch = Branch.find(params[:id])
        @branch.destroy

        redirect_to root_path, status: :see_other
    end

    private

    def branch_params
        params.require(:branch).permit(:name,:location)
    end
end
