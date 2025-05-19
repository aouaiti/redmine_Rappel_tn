class CostRate < ActiveRecord::Base
  self.table_name = 'tn_cost_rates'
  
  belongs_to :user
  belongs_to :project, optional: true
  
  validates :name, presence: true, length: { maximum: 255 }
  validates :rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :valid_from, presence: true
  validate :valid_to_after_valid_from
  
  scope :active, -> { where("valid_to IS NULL OR valid_to >= ?", Date.today) }
  scope :default, -> { where(is_default: true) }
  
  private
  
  def valid_to_after_valid_from
    return if valid_to.blank? || valid_from.blank?
    if valid_to < valid_from
      errors.add(:valid_to, "must be after valid from date")
    end
  end
end 