class BudgetCategory < ActiveRecord::Base
  self.table_name = 'tn_budget_categories'
  
  belongs_to :budget
  
  has_many :budget_items, dependent: :nullify
  
  validates :name, presence: true, length: { maximum: 255 }
  validates :color, format: { with: /\A#([A-Fa-f0-9]{6})\z/, message: "must be a valid hex color code" }
  validates :budget_id, presence: true
  
  # Temporarily commented out until acts_as_list gem is properly loaded
  # acts_as_list scope: :budget
  
  scope :ordered, -> { order(:position) }
  
  # Calculate total amount allocated to this category
  def amount
    budget_items.sum(:amount)
  end
  
  # Calculate total spent in this category
  def spent_amount
    budget_items.sum(&:spent_amount)
  end
  
  # Calculate remaining amount in this category
  def remaining_amount
    amount - spent_amount
  end
  
  # Calculate percentage spent in this category
  def percentage_spent
    return 0 if amount.zero?
    ((spent_amount / amount) * 100).round(2)
  end
  
  def total_amount
    budget_items.sum(:amount)
  end
end 