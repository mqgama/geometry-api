# frozen_string_literal: true

Kaminari.configure do |config|
  # Default number of items per page
  config.default_per_page = 20
  
  # Maximum number of items per page (security limit)
  config.max_per_page = 100
  
  # Number of pages to show in pagination window
  config.window = 4
  
  # Number of pages to show outside the window
  config.outer_window = 0
  
  # Number of pages to show on the left side of the current page
  config.left = 0
  
  # Number of pages to show on the right side of the current page
  config.right = 0
  
  # Method name for pagination
  config.page_method_name = :page
  
  # Parameter name for page number
  config.param_name = :page
  
  # Maximum number of pages to show
  config.max_pages = nil
  
  # Include params on first page
  config.params_on_first_page = false
end
