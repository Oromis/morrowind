source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
gem 'sprockets_uglifier_with_source_maps'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.0.3'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.3.2'
gem 'multi_json'
gem 'oj'
gem 'oj_mimic_json'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Rails server libs
gem 'rails-i18n'
gem 'breadcrumbs_on_rails', '~> 2.3'
gem 'paperclip', '~> 4.3'
gem 'bcrypt', '~> 3.1'
gem 'faker', '~> 1.4'

# Reading excel files
gem 'roo', '~> 2.3.0'

# For dumping the database into a file
gem 'yaml_db'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'sqlite3', '1.3.9'
  gem 'byebug', '3.4.0'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '1.1.3'
  gem 'therubyracer'
end

group :test do
  gem 'test-unit',          '1.2.3'
  gem 'minitest',           '5.8.1'
  gem 'minitest-reporters', '1.0.5'
  gem 'mini_backtrace',     '0.1.3'
  gem 'guard-minitest',     '2.3.1'
end

group :production do
  gem 'pg', '0.17.1'
  gem 'rails_12factor', '0.0.2'
end

