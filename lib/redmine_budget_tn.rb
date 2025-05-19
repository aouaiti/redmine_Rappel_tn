module RedmineBudgetTn
  class << self
    def apply_patches
      # Patch the project model directly without using modules
      Project.class_eval do
        # Define the association directly
        has_many :budgets, class_name: 'Budget', foreign_key: 'project_id', dependent: :destroy
        has_many :budget_items, through: :budgets
        
        # Total budget for all budgets in the project
        def total_budget
          budgets.sum(:amount) rescue 0
        end
        
        # Total spent across budgets
        def total_spent
          begin
            budgets.to_a.sum { |b| b.respond_to?(:spent_amount) ? b.spent_amount : 0 }
          rescue => e
            Rails.logger.error("Error calculating total_spent: #{e.message}")
            0
          end
        end
        
        # Remaining budget
        def remaining_budget
          begin
            total_budget - total_spent
          rescue => e
            Rails.logger.error("Error calculating remaining_budget: #{e.message}")
            0
          end
        end
        
        # Percentage spent
        def budget_percentage_spent
          begin
            return 0 if total_budget.zero?
            ((total_spent.to_f / total_budget.to_f) * 100).round(2)
          rescue => e
            Rails.logger.error("Error calculating budget_percentage_spent: #{e.message}")
            0
          end
        end
        
        # Active budgets
        def active_budgets
          begin
            budgets.select { |b| b.end_date.nil? || b.end_date >= Date.today }
          rescue => e
            Rails.logger.error("Error finding active_budgets: #{e.message}")
            []
          end
        end
        
        # Completed budgets
        def completed_budgets
          begin
            budgets.select { |b| b.end_date && b.end_date < Date.today }
          rescue => e
            Rails.logger.error("Error finding completed_budgets: #{e.message}")
            []
          end
        end
      end
      
      # Apply patches to other models if they exist
      if Object.const_defined?('Issue')
        Issue.class_eval do
          has_many :budget_items, class_name: 'BudgetItem', foreign_key: 'issue_id', dependent: :nullify
        end
      end
      
      if Object.const_defined?('TimeEntry')
        TimeEntry.class_eval do
          before_save :calculate_budget_cost
          
          def calculate_budget_cost
            # Simple implementation that can be expanded
            self.cost ||= hours * 25.0 rescue nil
          end
        end
      end
      
      Rails.logger.info "RedmineBudgetTn: Direct project patching completed successfully"
    end
  end
end

# Apply patches immediately
begin
  RedmineBudgetTn.apply_patches
rescue => e
  Rails.logger.error "Error applying RedmineBudgetTn patches: #{e.message}\n#{e.backtrace.join("\n")}"
end 