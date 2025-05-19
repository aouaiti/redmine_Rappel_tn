module RedmineBudgetTn
  module ProjectPatch
    def self.included(base)
      base.class_eval do
        has_many :budgets, class_name: 'Budget', dependent: :destroy
        has_many :budget_items, through: :budgets
        has_many :budget_categories, through: :budgets
      end
    end
    
    # Calculates the total budget for all budgets in the project
    def total_budget
      budgets.sum(:amount)
    end
    
    # Calculates the total spent amount across all budgets
    def total_spent
      budgets.sum(&:spent_amount)
    end
    
    # Calculates the remaining budget
    def remaining_budget
      total_budget - total_spent
    end
    
    # Gets the percentage of budget spent
    def budget_percentage_spent
      return 0 if total_budget.zero?
      ((total_spent / total_budget) * 100).round(2)
    end
    
    # Gets active budgets (those that haven't expired)
    def active_budgets
      budgets.select { |b| b.end_date.nil? || b.end_date >= Date.today }
    end
    
    # Gets completed budgets (those that have expired)
    def completed_budgets
      budgets.select { |b| b.end_date && b.end_date < Date.today }
    end
    
    # Gets budgets that are over their allocation
    def overbudget_budgets
      budgets.select { |b| b.spent_amount > b.amount }
    end
    
    # Gets the latest budget for the project
    def latest_budget
      budgets.order(created_at: :desc).first
    end
  end
end 