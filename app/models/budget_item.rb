class BudgetItem < ActiveRecord::Base
  self.table_name = 'tn_budget_items'
  
  include Redmine::SafeAttributes
  
  belongs_to :budget
  belongs_to :budget_category, optional: true
  belongs_to :issue, optional: true
  
  validates :name, presence: true, length: { maximum: 255 }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :hours, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  # Temporarily commented out until acts_as_list gem is properly loaded
  # acts_as_list scope: :budget
  
  delegate :project, to: :budget, allow_nil: true
  
  before_validation :set_calculated_amount
  
  # Types of budget items
  TYPES = %w(labor material fixed_cost expense contractor other)
  
  safe_attributes 'budget_id', 'budget_category_id', 'issue_id', 'name', 
                  'description', 'amount', 'hours', 'item_type'
  
  # Calculate the spent amount for this item
  def spent_amount
    begin
      return amount if item_type == 'fixed'
      
      if issue.present? && hours.present?
        issue.time_entries.sum(:hours) * (budget.try(:project).try(:cost_rate) || 0)
      else
        0
      end
    rescue => e
      Rails.logger.error("Error in BudgetItem#spent_amount: #{e.message}")
      0
    end
  end
  
  # Calculate the remaining amount
  def remaining_amount
    begin
      amount - spent_amount
    rescue => e
      Rails.logger.error("Error in BudgetItem#remaining_amount: #{e.message}")
      0
    end
  end
  
  # Calculate the percentage spent
  def percentage_spent
    begin
      return 0 if amount.zero?
      ((spent_amount.to_f / amount.to_f) * 100).round(2)
    rescue => e
      Rails.logger.error("Error in BudgetItem#percentage_spent: #{e.message}")
      0
    end
  end
  
  # Is this a fixed cost item?
  def fixed_cost?
    item_type == 'fixed_cost' || item_type == 'material'
  end
  
  # Get the default hourly rate to use
  def hourly_rate
    begin
      @hourly_rate ||= begin
        rate = project.try(:default_hourly_rate)
        rate ||= Setting.plugin_redmine_budget_tn['hourly_rate'].to_f rescue 25.0
        rate
      end
    rescue => e
      Rails.logger.error("Error in BudgetItem#hourly_rate: #{e.message}")
      25.0
    end
  end
  
  private
  
  # Set the calculated amount if specified in hours
  def set_calculated_amount
    begin
      if hours.present? && amount.nil?
        self.amount = hours * hourly_rate
      end
    rescue => e
      Rails.logger.error("Error in BudgetItem#set_calculated_amount: #{e.message}")
      self.amount ||= 0
    end
  end
end 