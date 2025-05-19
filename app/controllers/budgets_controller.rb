class BudgetsController < ApplicationController
  before_action :find_project_by_project_id
  before_action :authorize
  before_action :find_budget, only: [:show, :edit, :update, :destroy]
  
  def index
    @budgets = @project.budgets.order(created_at: :desc)
    
    # Add necessary calculations for the budget summary
    @percentage_spent = @project.budget_percentage_spent rescue 0
    @total_budget = @project.total_budget rescue 0
    @total_spent = @project.total_spent rescue 0
    @remaining_budget = @project.remaining_budget rescue 0
    
    # Get active and completed budgets
    @active_budgets = @project.active_budgets rescue []
    @completed_budgets = @project.completed_budgets rescue []
  rescue => e
    Rails.logger.error "Error in BudgetsController#index: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while loading budgets: #{e.message}"
  end
  
  def show
  rescue => e
    Rails.logger.error "Error in BudgetsController#show: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while loading budget: #{e.message}"
  end
  
  def new
    @budget = @project.budgets.build
    @budget.author = User.current
    @budget.start_date = Date.today
  rescue => e
    Rails.logger.error "Error in BudgetsController#new: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while creating new budget: #{e.message}"
  end
  
  def create
    @budget = @project.budgets.build
    @budget.author = User.current
    @budget.safe_attributes = params[:budget]
    
    if @budget.save
      flash[:notice] = 'Budget was successfully created.'
      redirect_to project_budget_path(@project, @budget)
    else
      render action: 'new'
    end
  rescue => e
    Rails.logger.error "Error in BudgetsController#create: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while saving budget: #{e.message}"
  end
  
  def edit
  rescue => e
    Rails.logger.error "Error in BudgetsController#edit: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while editing budget: #{e.message}"
  end
  
  def update
    @budget.safe_attributes = params[:budget]
    
    if @budget.save
      flash[:notice] = 'Budget was successfully updated.'
      redirect_to project_budget_path(@project, @budget)
    else
      render action: 'edit'
    end
  rescue => e
    Rails.logger.error "Error in BudgetsController#update: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while updating budget: #{e.message}"
  end
  
  def destroy
    if @budget.destroy
      flash[:notice] = 'Budget was successfully deleted.'
    else
      flash[:error] = 'Unable to delete budget.'
    end
    redirect_to project_budgets_path(@project)
  rescue => e
    Rails.logger.error "Error in BudgetsController#destroy: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while deleting budget: #{e.message}"
  end
  
  private
  
  def find_budget
    @budget = @project.budgets.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end 