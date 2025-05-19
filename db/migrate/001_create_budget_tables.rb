class CreateBudgetTables < ActiveRecord::Migration[6.0]
  def change
    create_table :tn_budgets, id: :integer do |t|
      t.integer :project_id, null: false
      t.integer :author_id, null: false
      t.string :name, null: false, limit: 255
      t.text :description
      t.decimal :amount, precision: 15, scale: 2, default: 0, null: false
      t.date :start_date, null: false
      t.date :end_date
      t.timestamps null: false
    end
    
    add_index :tn_budgets, :project_id
    add_index :tn_budgets, :author_id
    add_foreign_key :tn_budgets, :projects
    add_foreign_key :tn_budgets, :users, column: :author_id
    
    create_table :tn_budget_categories, id: :integer do |t|
      t.integer :budget_id, null: false
      t.string :name, null: false, limit: 255
      t.string :description, limit: 1000
      t.integer :position, default: 1
      t.string :color, limit: 7, default: '#3333FF'
      t.timestamps null: false
    end
    
    add_index :tn_budget_categories, :budget_id
    add_foreign_key :tn_budget_categories, :tn_budgets, column: :budget_id
    
    create_table :tn_budget_items, id: :integer do |t|
      t.integer :budget_id, null: false
      t.integer :budget_category_id
      t.integer :issue_id
      t.string :name, null: false, limit: 255
      t.text :description
      t.decimal :amount, precision: 15, scale: 2, default: 0, null: false
      t.decimal :hours, precision: 10, scale: 2
      t.string :item_type, limit: 50
      t.integer :position, default: 1
      t.timestamps null: false
    end
    
    add_index :tn_budget_items, :budget_id
    add_index :tn_budget_items, :budget_category_id
    add_index :tn_budget_items, :issue_id
    add_foreign_key :tn_budget_items, :tn_budgets, column: :budget_id
    add_foreign_key :tn_budget_items, :tn_budget_categories, column: :budget_category_id
    add_foreign_key :tn_budget_items, :issues
    
    create_table :tn_cost_rates, id: :integer do |t|
      t.integer :user_id, null: false
      t.integer :project_id
      t.string :name, null: false, limit: 255
      t.decimal :rate, precision: 15, scale: 2, null: false
      t.date :valid_from, null: false
      t.date :valid_to
      t.boolean :is_default, default: false
      t.timestamps null: false
    end
    
    add_index :tn_cost_rates, :user_id
    add_index :tn_cost_rates, :project_id
    add_foreign_key :tn_cost_rates, :users
    add_foreign_key :tn_cost_rates, :projects
    
    # Add cost column to time entries if it doesn't exist
    unless column_exists?(:time_entries, :cost)
      add_column :time_entries, :cost, :decimal, precision: 15, scale: 2
      add_column :time_entries, :tn_cost_rate_id, :integer
      add_index :time_entries, :tn_cost_rate_id
    end
  end
end 