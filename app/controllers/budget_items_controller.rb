class BudgetItemsController < ApplicationController
  before_action :find_project_by_project_id
  before_action :authorize
  before_action :find_item, only: [:edit, :update, :destroy]
  
  def index
    @items = @project.budgets.map(&:budget_items).flatten
    
    respond_to do |format|
      format.html
      format.js
      format.any { head :ok }
    end
  rescue => e
    Rails.logger.error "Error in BudgetItemsController#index: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while fetching budget items: #{e.message}"
  end
  
  def new
    @item = BudgetItem.new
    @item.budget_id = params[:budget_id] if params[:budget_id]
    @budgets = @project.budgets
    @categories = @project.budgets.map(&:budget_categories).flatten.uniq
    
    respond_to do |format|
      format.html
      format.js
      format.any { head :ok }
    end
  rescue => e
    Rails.logger.error "Error in BudgetItemsController#new: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while creating new budget item: #{e.message}"
  end
  
  def create
    @item = BudgetItem.new
    @item.safe_attributes = params[:budget_item]
    
    respond_to do |format|
      if @item.save
        flash[:notice] = 'Budget item was successfully created.'
        format.html { redirect_back_or_default project_budget_path(@project, @item.budget) }
        format.js
        format.any { head :ok }
      else
        @budgets = @project.budgets
        @categories = @project.budgets.map(&:budget_categories).flatten.uniq
        format.html { render action: 'new' }
        format.js
        format.any { head :unprocessable_entity }
      end
    end
  rescue => e
    Rails.logger.error "Error in BudgetItemsController#create: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while saving budget item: #{e.message}"
  end
  
  def edit
    @budgets = @project.budgets
    @categories = @project.budgets.map(&:budget_categories).flatten.uniq
    
    respond_to do |format|
      format.html
      format.js
      format.any { head :ok }
    end
  rescue => e
    Rails.logger.error "Error in BudgetItemsController#edit: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while editing budget item: #{e.message}"
  end
  
  def update
    @item.safe_attributes = params[:budget_item]
    
    respond_to do |format|
      if @item.save
        flash[:notice] = 'Budget item was successfully updated.'
        format.html { redirect_to project_budget_path(@project, @item.budget) }
        format.js
        format.any { head :ok }
      else
        @budgets = @project.budgets
        @categories = @project.budgets.map(&:budget_categories).flatten.uniq
        format.html { render action: 'edit' }
        format.js
        format.any { head :unprocessable_entity }
      end
    end
  rescue => e
    Rails.logger.error "Error in BudgetItemsController#update: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while updating budget item: #{e.message}"
  end
  
  def destroy
    budget = @item.budget
    
    respond_to do |format|
      if @item.destroy
        flash[:notice] = 'Budget item was successfully deleted.'
      else
        flash[:error] = 'Unable to delete budget item.'
      end
      format.html { redirect_to project_budget_path(@project, budget) }
      format.js
      format.any { head :ok }
    end
  rescue => e
    Rails.logger.error "Error in BudgetItemsController#destroy: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while deleting budget item: #{e.message}"
  end
  
  private
  
  def find_item
    @item = BudgetItem.find(params[:id])
    unless @item.budget.project == @project
      render_403
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end 