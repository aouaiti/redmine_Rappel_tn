require 'redmine'
require 'acts_as_list'
require_relative 'lib/redmine_budget_tn'

# Add translations for menu items
Redmine::Plugin.register :redmine_budget_tn do
  name 'Suivi Budgétaire'
  author 'Aouaiti'
  description 'Un plugin de gestion de budget professionnel pour Redmine'
  version '1.0.0'
  url 'https://github.com/aouaiti/redmine_Budget_tn'
  
  requires_redmine version_or_higher: '4.2.0'
  
  settings default: {
    'default_currency' => 'TND',
    'currency_format' => '%n %u',
    'currency_separator' => ',',
    'currency_delimiter' => ' ',
    'hourly_rate' => '25'
  }, partial: 'settings/budget_settings'
  
  # Add translations
  Rails.configuration.to_prepare do
    I18n.backend.store_translations :en, label_budget_plural: 'Budgets'
    I18n.backend.store_translations :en, label_budget_reports: 'Budget Reports'
    I18n.backend.store_translations :fr, label_budget_plural: 'Budgets'
    I18n.backend.store_translations :fr, label_budget_reports: 'Rapports de budget'
  end
  
  # Permissions for the plugin
  project_module :budget do
    permission :view_budgets, { 
      budgets: [:index, :show],
      budget_reports: [:index, :show, :details]
    }, read: true
    
    permission :manage_budgets, { 
      budgets: [:new, :create, :edit, :update, :destroy],
      budget_items: [:new, :create, :edit, :update, :destroy],
      budget_categories: [:index, :new, :create, :edit, :update, :destroy]
    }
    
    permission :view_budget_reports, {
      budget_reports: [:index, :show, :details, :export]
    }, read: true
  end
  
  begin
    # Only add menu items if the controllers exist
    menu :project_menu, :budgets, 
      { controller: 'budgets', action: 'index' }, 
      caption: 'Budgets', 
      after: :activity,
      param: :project_id,
      if: Proc.new { |p| User.current.allowed_to?(:view_budgets, p) rescue false }
      
    menu :project_menu, :budget_reports, 
      { controller: 'budget_reports', action: 'index' }, 
      caption: 'Budget Reports', 
      after: :budgets,
      param: :project_id,
      if: Proc.new { |p| User.current.allowed_to?(:view_budget_reports, p) rescue false }
      
    # Add administration menu link
    menu :admin_menu, :budget_settings,
      { controller: 'settings', action: 'plugin', id: 'redmine_budget_tn' },
      caption: 'Budget Settings'
  rescue => e
    Rails.logger.error "Error registering menu items: #{e.message}"
  end
end

# Register additional assets
Rails.application.config.assets.precompile += %w(redmine_budget_tn.css budget_charts.js)

# Apply patches with both approaches for redundancy
Rails.configuration.to_prepare do
  begin
    # Let's try a more direct approach to make sure the associations are defined
    unless Project.method_defined?(:budgets)
      # Try to apply the patches directly
      RedmineBudgetTn.apply_patches
    end
  rescue => e
    Rails.logger.error "Error in RedmineBudgetTn plugin initialization: #{e.message}\n#{e.backtrace.join("\n")}"
  end
end 
