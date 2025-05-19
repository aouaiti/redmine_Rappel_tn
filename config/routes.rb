Rails.application.routes.draw do
  resources :projects do
    resources :budgets
    
    resources :budget_reports, only: [:index, :show] do
      collection do
        get 'details'
        get 'export'
      end
    end
    
    resources :budget_categories
    resources :budget_items
  end
end 