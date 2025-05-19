module RedmineBudgetTn
  module TimeEntryPatch
    def self.included(base)
      base.class_eval do
        before_save :calculate_cost
        attr_accessor :cost_rate_id
        
        belongs_to :cost_rate, optional: true
      end
    end
    
    # Calculate the cost based on hours and user's cost rate
    def calculate_cost
      self.cost ||= begin
        rate = if cost_rate_id.present?
                 CostRate.find_by(id: cost_rate_id)
               else
                 user.default_cost_rate_for(project)
               end
        
        if rate
          hours * rate.rate
        else
          # Default fallback rate from settings
          default_rate = Setting.plugin_redmine_budget_tn['hourly_rate'].to_f
          hours * default_rate
        end
      end
    end
    
    # Calculate total cost for a collection of time entries
    def self.total_cost(time_entries)
      time_entries.sum(&:cost)
    end
  end
end 