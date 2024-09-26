class MedicinesController < ApplicationController
    before_action :set_branch
    before_action :set_medicine, only: [:show, :edit, :update, :destroy]
    after_action :verify_authorized


    def index
        @medicines = @branch.medicines
        authorize @medicines
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
        authorize @medicine

        if @medicine.save
            redirect_to branch_medicine_path(@branch, @medicine), notice: "Medicine was created succesfully."
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit
        authorize @medicine
    end

    def update
        authorize @medicine
        if @medicine.update(medicine_params)
            redirect_to branch_medicine_path(@branch, @medicine), notice: "Medicine Succesfully Updated."
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        authorize @medicine
        @medicine.destroy
        redirect_to branch_medicines_path(@branch), notice: "Medicine was succesfully deleted."
    end

    private

    def set_branch
        @branch = Branch.find(params[:branch_id])
    end

    def set_medicine
        @medicine = @branch.medicines.find(params[:id])
    end

    def medicine_params
        params.require(:medicine).permit(:name,:description,:price,:stock_quantity,:expiry_date)
    end
end
