class BudgetReportsController < ApplicationController
  before_action :find_project_by_project_id
  before_action :authorize
  
  def index
    @budgets = @project.budgets.order(created_at: :desc)
    
    # Project budget summary
    @total_budget = @project.total_budget
    @total_spent = @project.total_spent
    @remaining_budget = @project.remaining_budget
    
    # Time period filtering defaults
    @start_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.today.beginning_of_month
    @end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today.end_of_month
    
    respond_to do |format|
      format.html
      format.js
      format.any { head :ok }
    end
  rescue => e
    Rails.logger.error "Error in BudgetReportsController#index: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while loading budget reports: #{e.message}"
  end
  
  def show
    @report_type = params[:type] || 'summary'
    
    respond_to do |format|
      format.html do
        case @report_type
        when 'summary'
          render action: 'summary'
        when 'details'
          render action: 'details'
        else
          render action: 'summary'
        end
      end
      format.js
      format.any { head :ok }
    end
  rescue => e
    Rails.logger.error "Error in BudgetReportsController#show: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while loading budget report: #{e.message}"
  end
  
  def details
    @budget = @project.budgets.find(params[:budget_id]) if params[:budget_id]
    @budget_items = @budget ? @budget.budget_items : @project.budget_items
    
    respond_to do |format|
      format.html
      format.js
      format.any { head :ok }
    end
  rescue => e
    Rails.logger.error "Error in BudgetReportsController#details: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while loading budget details: #{e.message}"
  end
  
  def export
    respond_to do |format|
      format.csv { send_data generate_csv_report, filename: "budget_report_#{@project.identifier}_#{Date.today}.csv" }
      format.html { redirect_to project_budget_reports_path(@project) }
      format.js
      format.any { head :ok }
    end
  rescue => e
    Rails.logger.error "Error in BudgetReportsController#export: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error message: "An error occurred while exporting budget report: #{e.message}"
  end
  
  private
  
  def generate_csv_report
    # Placeholder for CSV generation functionality
    "Project,Budget,Amount,Spent,Remaining\n#{@project.name},Total,#{@project.total_budget},#{@project.total_spent},#{@project.remaining_budget}"
  end
end 