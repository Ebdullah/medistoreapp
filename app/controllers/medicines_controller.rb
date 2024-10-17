class MedicinesController < ApplicationController
    before_action :set_branch
    before_action :set_medicine, only: [:edit, :show, :update, :destroy]
    after_action :verify_authorized


    def index
        per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 5

        @medicines = @branch.medicines.active.page(params[:page]).per(per_page)
        authorize @medicines

        respond_to do |format|
            format.html
            format.json { render json: @medicines }
        end
    end

    def show
        authorize @medicine
    end

    def new
        @medicine = @branch.medicines.build
        authorize @medicine
    end

    def create
        @medicine = @branch.medicines.build(medicine_params)
        return @medicine.errors if @medicine.stock_quantity <= 0
        authorize @medicine

        if @medicine.save
            redirect_to branch_medicine_path(@branch, @medicine), notice: "Medicine was created succesfully."
        else
            flash[:alert] = @medicine.errors.full_messages.map { |msg| msg.gsub(/^Name\s/, '') }.join(", ")
            Rails.logger.error(@medicine.errors.full_messages)
            render :new, status: :unprocessable_entity
        end
    end

    def edit
        authorize @medicine
    end

    def update
        authorize @medicine
    
        if @medicine.update(medicine_params)
          redirect_to branch_medicine_path(@branch, @medicine), notice: "Medicine Successfully Updated."
        else
          flash.now[:alert] = "Error updating medicine." 
          render :edit, status: :unprocessable_entity
        end
      end

    def destroy
        authorize @medicine
        @medicine.destroy
        redirect_to branch_medicines_path(@branch), notice: "Medicine was succesfully deleted."
    end

    def expired
        authorize Medicine
        @expired_medicines = Medicine.where(expired: true).order(:expiry_date)
    end

    def price
        @medicine = Medicine.find(params[:id])
        render json: { price: @medicine.price }
    end

    private

    def set_branch
        @branch = Branch.find(params[:branch_id])
    end

    def set_medicine
        @medicine = @branch.medicines.find(params[:id])
    end

    def medicine_params
        params.require(:medicine).permit(:name,:description,:price,:stock_quantity,:expiry_date,:expired, :sku)
    end
end
