require "prawn/measurement_extensions"

PrawnRails.config do |config|
  config.page_layout = :portrait
  config.page_size   = "A4"
  config.skip_page_creation = false
  config.margin = 0.7.in
  config.font_size = 12
end
