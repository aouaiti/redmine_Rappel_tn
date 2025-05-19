# Redmine Budget TN Plugin

A comprehensive budget management plugin for Redmine, with Tunisian Dinar (TND) support and French localization. This plugin allows project managers to create and manage budgets, track expenses, and generate detailed reports.

## Features

- Create multiple budgets per project
- Track budget expenses and remaining amounts
- Assign budget items to categories and issues
- Visual budget reporting with charts
- TND currency support (Tunisian Dinar)
- French localization
- Compatible with Redmine 6.x and Rails 6.x
- Comprehensive budget summary and detailed reports
- CSV export functionality

## Requirements

- Redmine 6.x
- Rate plugin (dependency)

## Installation

1. Clone this repository into your Redmine plugins directory:
   ```
   cd {REDMINE_ROOT}/plugins
   git clone https://github.com/YOUR-USERNAME/redmine_budget_tn.git
   ```

2. Install required dependencies:
   ```
   bundle install
   ```

3. Run the plugin migrations:
   ```
   bundle exec rake redmine:plugins:migrate RAILS_ENV=production
   ```

4. Restart your Redmine application:
   ```
   touch tmp/restart.txt
   ```

## Usage

1. Enable the plugin in your project settings
2. Navigate to the "Budgets" tab in your project
3. Create a new budget by specifying name, amount, and date range
4. Add budget items to track specific expenses 
5. View budget reports to analyze spending patterns

## Budget Reports

The plugin provides two main types of reports:

- **Summary Report**: Shows an overview of all project budgets including total amount, spent and remaining amounts
- **Detailed Report**: Shows specific budget items, categories, and spending distribution for a selected budget

## Configuration

- Project administrators can enable/disable budget features per project
- Each budget can be configured with different start/end dates and categories
- View permissions can be set through the Redmine roles and permissions system

## License

This plugin is released under the MIT License.

## Credits

This plugin is based on the original Budget Plugin for Redmine, with enhancements for TND currency support, French localization, and Redmine 6 compatibility. 
