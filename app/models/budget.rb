class Budget < ActiveRecord::Base
  self.table_name = 'tn_budgets'
  
  include Redmine::SafeAttributes
  
  belongs_to :project
  belongs_to :author, class_name: 'User'
  
  has_many :budget_items, dependent: :destroy
  has_many :budget_categories, dependent: :destroy
  
  validates :project_id, presence: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 2000 }, allow_blank: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :start_date, presence: true
  validate :end_date_after_start_date
  
  safe_attributes 'name', 'description', 'amount', 'start_date', 'end_date'
  
  scope :active, -> { where("end_date IS NULL OR end_date >= ?", Date.today) }
  scope :completed, -> { where("end_date < ?", Date.today) }
  scope :recent, -> { order(created_at: :desc) }
  
  before_validation :set_default_dates
  
  # Calculate spent amount based on included budget items
  def spent_amount
    begin
      budget_items.sum(:amount)
    rescue => e
      Rails.logger.error("Error in Budget#spent_amount: #{e.message}")
      0
    end
  end
  
  # Calculate remaining budget
  def remaining_amount
    begin
      amount - spent_amount
    rescue => e
      Rails.logger.error("Error in Budget#remaining_amount: #{e.message}")
      0
    end
  end
  
  # Calculate percentage spent
  def percentage_spent
    begin
      return 0 if amount.zero?
      ((spent_amount.to_f / amount.to_f) * 100).round(2)
    rescue => e
      Rails.logger.error("Error in Budget#percentage_spent: #{e.message}")
      0
    end
  end
  
  # Check if budget is over spent
  def over_budget?
    begin
      spent_amount > amount
    rescue => e
      Rails.logger.error("Error in Budget#over_budget?: #{e.message}")
      false
    end
  end
  
  # Get a breakdown of spending by category
  def spending_by_category
    begin
      categories = {}
      
      budget_categories.each do |category|
        items = budget_items.where(budget_category_id: category.id)
        categories[category.name] = {
          budget: items.sum(:amount),
          spent: items.sum { |i| i.respond_to?(:spent_amount) ? i.spent_amount : 0 },
          remaining: items.sum(:amount) - items.sum { |i| i.respond_to?(:spent_amount) ? i.spent_amount : 0 }
        }
      end
      
      categories
    rescue => e
      Rails.logger.error("Error in Budget#spending_by_category: #{e.message}")
      {}
    end
  end
  
  private
  
  def set_default_dates
    self.start_date ||= Date.today
  end
  
  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end 