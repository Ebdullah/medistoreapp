class ArchivesController < ApplicationController

    before_action :set_branch

    def index
      per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 5
      @archives = Archive.where(branch_id: @branch.id).order(deleted_at: :desc).page(params[:page]).per(per_page)
    #   @archives = @branch.archives.includes(:user, :record)
    end
  
  
    private
  
    def set_branch
      @branch = Branch.find(params[:branch_id]) 
    end
  end
