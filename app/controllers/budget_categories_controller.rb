class BudgetCategoriesController < ApplicationController
  before_action :find_project_by_project_id
  before_action :authorize
  before_action :find_category, only: [:edit, :update, :destroy]
  
  def index
    @categories = @project.budgets.map(&:budget_categories).flatten.uniq
  rescue => e
    Rails.logger.error "Error in BudgetCategoriesController#index: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while loading budget categories: #{e.message}"
  end
  
  def new
    @category = BudgetCategory.new
    @budgets = @project.budgets
  rescue => e
    Rails.logger.error "Error in BudgetCategoriesController#new: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while creating new budget category: #{e.message}"
  end
  
  def create
    @category = BudgetCategory.new
    @category.safe_attributes = params[:budget_category]
    
    if @category.save
      flash[:notice] = 'Budget category was successfully created.'
      redirect_to project_budget_categories_path(@project)
    else
      @budgets = @project.budgets
      render action: 'new'
    end
  rescue => e
    Rails.logger.error "Error in BudgetCategoriesController#create: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while saving budget category: #{e.message}"
  end
  
  def edit
    @budgets = @project.budgets
  rescue => e
    Rails.logger.error "Error in BudgetCategoriesController#edit: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while editing budget category: #{e.message}"
  end
  
  def update
    @category.safe_attributes = params[:budget_category]
    
    if @category.save
      flash[:notice] = 'Budget category was successfully updated.'
      redirect_to project_budget_categories_path(@project)
    else
      @budgets = @project.budgets
      render action: 'edit'
    end
  rescue => e
    Rails.logger.error "Error in BudgetCategoriesController#update: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while updating budget category: #{e.message}"
  end
  
  def destroy
    if @category.destroy
      flash[:notice] = 'Budget category was successfully deleted.'
    else
      flash[:error] = 'Unable to delete budget category.'
    end
    redirect_to project_budget_categories_path(@project)
  rescue => e
    Rails.logger.error "Error in BudgetCategoriesController#destroy: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while deleting budget category: #{e.message}"
  end
  
  private
  
  def find_category
    @category = BudgetCategory.find(params[:id])
    unless @category.budget.project == @project
      render_403
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end 