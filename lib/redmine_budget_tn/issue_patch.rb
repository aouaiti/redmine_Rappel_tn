module RedmineBudgetTn
  module IssuePatch
    def self.included(base)
      base.class_eval do
        has_many :budget_items, dependent: :nullify
      end
    end
    
    # Get the budget item associated with this issue
    def budget_item
      budget_items.first
    end
    
    # Get the budget allocation for this issue
    def budget_amount
      budget_items.sum(:amount)
    end
    
    # Calculate spent amount for this issue based on time entries
    def budget_spent
      time_entries.sum("hours * COALESCE(cost, 0)")
    end
    
    # Calculate remaining budget for this issue
    def budget_remaining
      budget_amount - budget_spent
    end
    
    # Calculate percentage of budget spent
    def budget_percentage_spent
      return 0 if budget_amount.zero?
      ((budget_spent / budget_amount) * 100).round(2)
    end
    
    # Check if issue is over budget
    def over_budget?
      budget_spent > budget_amount
    end
  end
end 